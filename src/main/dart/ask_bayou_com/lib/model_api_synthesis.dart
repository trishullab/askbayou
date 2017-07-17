/*
Copyright 2016 Rice University

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/
library model.api_synthesis;
import 'dart:async';
import 'dart:html';
import 'dart:convert';

part 'src/model/api_synthesis/synthesiser.dart';
part 'src/model/api_synthesis/synthesiser_websocket.dart';
part 'src/model/api_synthesis/synthesiser_http.dart';
part 'src/model/api_synthesis/synthesiser_do_nothing.dart';
part 'src/model/api_synthesis/json_response_completer.dart';

void _parseResponseAndActivateCompleter(String json, Completer<SynthesiseResult> completer)
{
  Map responseMap;
  {
    responseMap = JSON.decode(json);
  }

  String SUCCESS = "success";
  if(!responseMap.containsKey(SUCCESS))
  {
    completer.completeError("JSON response does not contain success field.", StackTrace.current);
    return;
  }

  bool success = responseMap[SUCCESS];

  if(!success)
  {
    String ERROR_MESSAGE = "errorMessage";
    if(!responseMap.containsKey(ERROR_MESSAGE))
    {
      completer.completeError("Unspecified JSON error response.", StackTrace.current);
      return;
    }

    String errorMsg = responseMap[ERROR_MESSAGE].toString();
    completer.completeError(errorMsg, StackTrace.current);
    return;
  }

  String RESULTS = "results";
  if(!responseMap.containsKey(RESULTS))
  {
    completer.completeError("JSON response does not contain results field", StackTrace.current);
    return;
  }

  String REQUEST_ID = "requestId";
  if(!responseMap.containsKey(REQUEST_ID))
  {
    completer.completeError("JSON response does not contain requestId field", StackTrace.current);
    return;
  }

  List<String> results = responseMap[RESULTS];
  String requetId = responseMap[REQUEST_ID];

  completer.complete(new SynthesiseResult(results, requetId));
}