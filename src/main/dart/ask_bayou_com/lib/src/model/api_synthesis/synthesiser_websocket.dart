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
part of model.api_synthesis;

/**
 * A Synthesiser that delegates the synthesis process to another process reachable via a WebSocket.
 */
class SynthesiserWebSocket extends Synthesiser
{
  /**
   * The WebSocket address of the delegate process.
   */
  String _endpoint;

  /**
   * Creates a SynthesiserWebSocket that communicates over a WebSocket to the given endpoint address.
   */
  SynthesiserWebSocket(this._endpoint);

  @override
  Future<List<String>> synthesise(String code)
  {
    Completer<List<String>> completer = new Completer();

    WebSocket webSocket = new WebSocket(_endpoint); // connects socket as a function of construction

    webSocket.onError.listen((Event event)
    {
      completer.completeError("Websocket error.", StackTrace.current);
    });

    webSocket.onClose.listen((Event event)
    {
      if(completer.isCompleted)
        return;

      completer.completeError("Premature websocket close.", StackTrace.current);
    });

    /**
     * Register to receive a response message and parse it to get results.
     */
    webSocket.onMessage.listen((MessageEvent e)
    {
      _parseResponseAndActivateCompleter(e.data.toString(), completer);
    });

    /**
     * When WebSocket opens, send initial message with synthesis request.
     */
    webSocket.onOpen.listen((Event event)
    {
      Map<String,String> requestMap = { "code" : code };
      String json = JSON.encode(requestMap);
      webSocket.sendString(json);
    });

    return completer.future;

  }
}