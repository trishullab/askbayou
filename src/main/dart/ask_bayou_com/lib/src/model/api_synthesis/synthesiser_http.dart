/*
Copyright 2017 Rice University

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

part of model.api_synthesis;

class SynthesiserHttp implements Synthesiser
{
  final String _synthesiseEndpointUrl;

  SynthesiserHttp(this._synthesiseEndpointUrl);

  @override
  Future<SynthesiseResult> synthesise(String code)
  {
    Completer<SynthesiseResult> completer = new Completer();

    HttpRequest request = new HttpRequest();

    request.onReadyStateChange.listen((_)
    {
      if (request.readyState == HttpRequest.DONE)
      {
          if(request.status != 200 && request.status != 400)
          {
            completer.completeError("Response code: " + request.status.toString(), StackTrace.current);
            return;
          }

          _parseResponseAndActivateCompleter(request.responseText, completer);
      }
    });

    request.open("POST", _synthesiseEndpointUrl);

    Map<String,String> requestMap = { "code" : code };
    String json = JSON.encode(requestMap);
    request.send(json);

    return completer.future;
  }
}
