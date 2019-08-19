#
# Copyright (c) 2019 cTuning foundation.
# See CK COPYRIGHT.txt for copyright details.
#
# SPDX-License-Identifier: BSD-3-Clause.
# See CK LICENSE.txt for licensing details.
#

import os
import json

MLPERF_LOG_TRACE_JSON    = 'mlperf_log_trace.json'
MLPERF_LOG_ACCURACY_JSON = 'mlperf_log_accuracy.json'
MLPERF_LOG_DETAIL_TXT    = 'mlperf_log_detail.txt'
MLPERF_LOG_SUMMARY_TXT   = 'mlperf_log_summary.txt'

TEST_SCENARIO_OFFLINE_JSON       = 'TestScenario.Offline.json'
TEST_SCENARIO_SINGLESTREAM_JSON  = 'TestScenario.SingleStream.json'
TEST_SCENARIO_MULTISTREAM_JSON   = 'TestScenario.MultiStream.json'
TEST_SCENARIO_SERVER_JSON        = 'TestScenario.Server.json'

def ck_postprocess(i):
  print('\n--------------------------------')

  save_dict = {}
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

  with open('tmp-ck-timer.json', 'w') as save_file:
    json.dump(save_dict, save_file, indent=2, sort_keys=True)

  print('--------------------------------\n')
  return {'return': 0}

