#
# Copyright (c) 2019 cTuning foundation.
# See CK COPYRIGHT.txt for copyright details.
#
# SPDX-License-Identifier: BSD-3-Clause.
# See CK LICENSE.txt for licensing details.
#

import os
import json
import re

from pprint import pprint
from subprocess import check_output

MLPERF_LOG_ACCURACY_JSON = 'mlperf_log_accuracy.json'
MLPERF_LOG_DETAIL_TXT    = 'mlperf_log_detail.txt'
MLPERF_LOG_SUMMARY_TXT   = 'mlperf_log_summary.txt'
MLPERF_LOG_TRACE_JSON    = 'mlperf_log_trace.json'
RESULTS_JSON             = 'results.json'
COCO_RESULTS_JSON        = 'coco-results.json'

def ck_postprocess(i):
  print('\n--------------------------------')

  env = i['env']

  save_dict = {}
  save_dict['execution_time'] = 0.0

  # Save logs.
  save_dict['mlperf_log'] = {}
  mlperf_log_dict = save_dict['mlperf_log']

  if os.stat(MLPERF_LOG_TRACE_JSON).st_size==0:
    mlperf_log_dict['trace'] = {}
  else:
    with open(MLPERF_LOG_TRACE_JSON, 'r') as trace_file:
      mlperf_log_dict['trace'] = json.load(trace_file)

  with open(MLPERF_LOG_ACCURACY_JSON, 'r') as accuracy_file:
    mlperf_log_dict['accuracy'] = json.load(accuracy_file)

  with open(MLPERF_LOG_SUMMARY_TXT, 'r') as summary_file:
    mlperf_log_dict['summary'] = summary_file.readlines()

  with open(MLPERF_LOG_DETAIL_TXT, 'r') as detail_file:
    mlperf_log_dict['detail'] = detail_file.readlines()

  # Read output.
  try:
      with open(RESULTS_JSON, 'r') as results_file:
        save_dict['results'] = json.load(results_file)
  except:
    pass

  # Check accuracy in accuracy mode.
  accuracy_mode = False
  if mlperf_log_dict['accuracy'] != []:
    accuracy_mode = True

  if accuracy_mode:
    deps = i['deps']
    python_bin = deps['python']['dict']['env']['CK_PYTHON_BIN']
    accuracy_script = os.path.join( deps['mlperf-inference-src']['dict']['env']['CK_ENV_MLPERF_INFERENCE_V05'],
                                    'classification_and_detection', 'tools', 'accuracy-coco.py' )
    coco_dir = deps['dataset']['dict']['env']['CK_ENV_DATASET_COCO']

    pythonpath_coco = deps['tool-coco']['dict']['env']['PYTHONPATH'].split(':')[0]
    pythonpath_matplotlib = deps['lib-python-matplotlib']['dict']['env']['PYTHONPATH'].split(':')[0]
    os.environ['PYTHONPATH'] = pythonpath_matplotlib+':'+pythonpath_coco+':'+os.environ.get('PYTHONPATH','')
    command = [ python_bin, accuracy_script, '--mlperf-accuracy-file', MLPERF_LOG_ACCURACY_JSON, '--coco-dir', coco_dir ]
    output = check_output(command)
    # The last line is e.g. "mAP=13.323%".
    mAP_percent_line = output.splitlines()[-1].decode('utf-8')

    searchObj = re.search('mAP\=([\d\.]+)\%', mAP_percent_line)
    if searchObj:
        mAP_percent = float(searchObj.group(1))
    else:
        print("Could not parse mAP out of the following string: <<" + mAP_percent_line + ">>")

    save_dict['accuracy_mAP_pc'] = mAP_percent
    save_dict['accuracy_mAP'] = mAP_percent * 0.01
    ck.out('mAP=%.3f%% (from the postprocessing script)' % save_dict['accuracy_mAP_pc'])
    # Save COCO results generated by running the above script.
    with open(COCO_RESULTS_JSON, 'r') as coco_results_file:
      save_dict['results-coco'] = json.load(coco_results_file)

  for scenario_name in [ 'SingleStream', 'MultiStream', 'Server', 'Offline' ]:
    scenario_key = 'TestScenario.%s' % scenario_name
    if 'results' in save_dict:
        scenario = save_dict['results'].get(scenario_key, None)

        if scenario: # FIXME: Assumes only a single scenario is valid.
          save_dict['execution_time_s']  = scenario.get('took', 0.0)
          save_dict['execution_time_ms'] = scenario.get('took', 0.0) * 1000
          save_dict['percentiles'] = scenario.get('percentiles', {})
          save_dict['qps'] = scenario.get('qps', 0)
          if accuracy_mode:
            ck.out('mAP=%.3f%% (from the results for %s)' % (scenario.get('mAP', 0.0) * 100.0, scenario_key))

  # save_dict['execution_time'] = save_dict['execution_time_s']
  with open('tmp-ck-timer.json', 'w') as save_file:
    json.dump(save_dict, save_file, indent=2, sort_keys=True)

  print('--------------------------------\n')
  return {'return': 0}

