part of model.api_synthesis;

class SynthesiserHttp implements Synthesiser
{
  final String _synthesiseEndpointUrl;

  SynthesiserHttp(this._synthesiseEndpointUrl);

  @override
  Future<List<String>> synthesise(String code)
  {
    Completer<List<String>> completer = new Completer();

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
