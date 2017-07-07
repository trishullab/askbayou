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
part of model.result_quality_feedback;

class ResultQualityFeedbackRepositoryHttp implements ResultQualityFeedbackRepository
{

  final String _synthesiseFeedbackEndpointUrl;

  ResultQualityFeedbackRepositoryHttp(this._synthesiseFeedbackEndpointUrl);

  @override
  Future addFeedback(String requestId, String searchCode, String result, bool isGood)
  {
    Completer completer = new Completer();

    HttpRequest request = new HttpRequest();

    request.onReadyStateChange.listen((_)
      {
        if (request.readyState == HttpRequest.DONE)
        {
          if(request.status != 200)
          {
            completer.completeError("Response code: " + request.status.toString(), StackTrace.current);
            return;
          }

          completer.complete();
        }
      });

    request.open("POST", _synthesiseFeedbackEndpointUrl);

    Map<String,String> requestMap = { "requestId" : requestId, "searchCode" : searchCode, "resultCode" : result,
                                      "isGood" : isGood.toString() };
    String json = JSON.encode(requestMap);
    request.send(json);

    return completer.future;
  }
}
