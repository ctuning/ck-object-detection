#
# Copyright (c) 2019 cTuning foundation.
# See CK COPYRIGHT.txt for copyright details.
#
# SPDX-License-Identifier: BSD-3-Clause.
# See CK LICENSE.txt for licensing details.
#

import os
import json

MLPERF_LOG_ACCURACY_JSON = 'mlperf_log_accuracy.json'
MLPERF_LOG_DETAIL_TXT    = 'mlperf_log_detail.txt'
MLPERF_LOG_SUMMARY_TXT   = 'mlperf_log_summary.txt'
MLPERF_LOG_TRACE_JSON    = 'mlperf_log_trace.json'
OUTPUT_JSON              = 'output.json'

def ck_postprocess(i):
  print('\n--------------------------------')

  env = i['env']

  save_dict = {}
  save_dict['execution_time'] = 0.0

  # Save logs.
  save_dict['mlperf_log'] = {}
  mlperf_log_dict = save_dict['mlperf_log']

  with open(MLPERF_LOG_TRACE_JSON, 'r') as trace_file:
    mlperf_log_dict['trace'] = json.load(trace_file)

  with open(MLPERF_LOG_ACCURACY_JSON, 'r') as accuracy_file:
    mlperf_log_dict['accuracy'] = json.load(accuracy_file)

  with open(MLPERF_LOG_SUMMARY_TXT, 'r') as summary_file:
    mlperf_log_dict['summary'] = summary_file.readlines()

  with open(MLPERF_LOG_DETAIL_TXT, 'r') as detail_file:
    mlperf_log_dict['detail'] = detail_file.readlines()

  # Read output.
  with open(OUTPUT_JSON, 'r') as output_file:
    save_dict['output'] = json.load(output_file)

  # Only save results for those scenarios that appear in the output
  # to ensure that only the latest results get recorded.
  save_dict['scenarios'] = {}
  scenarios_dict = save_dict['scenarios']

  for scenario in [ 'SingleStream', 'MultiStream', 'Server', 'Offline' ]:
    scenario_json = 'TestScenario.%s.json' % scenario
    scenario_key  = 'TestScenario.%s' % scenario
    # NB: Scenario 'Server' gives key 'TestScenario.Server-<max latency>'.
    if scenario == 'Server': scenario_key += '-%s' % env.get('CK_MAX_LATENCY', 0.1)
    scenario_dict = save_dict['output'].get(scenario_key, {})
    if scenario_dict != {}:
      with open(scenario_json, 'r') as scenario_file:
        scenarios_dict[scenario] = json.load(scenario_file)
        save_dict['execution_time'] += scenario_dict['took']

  with open('tmp-ck-timer.json', 'w') as save_file:
    json.dump(save_dict, save_file, indent=2, sort_keys=True)

  print('--------------------------------\n')
  return {'return': 0}

