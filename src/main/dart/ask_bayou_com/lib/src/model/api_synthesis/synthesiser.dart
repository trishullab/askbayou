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
 * Takes a code with API evidence and a code hole and synthesises results.
 *
 * For example in the Java language:
 *
 * //[
 *  //    [
 *  //        "java.io.FileReader.FileReader(java.lang.String)",
 *  //        "java.io.BufferedReader.BufferedReader(java.io.Reader)",
 *  //        "java.io.BufferedReader.readLine()",
 *  //        "java.io.BufferedReader.readLine()",
 *  //        "java.io.BufferedReader.close()"
 *  //    ]
 *  //]
 *  import java.io.FileWriter;
 *  import android.bluetooth.BluetoothSocket;
 *
 *  public class TestIO {
 *
 *  void __datasyn_fill(String file, FileWriter writer, BluetoothSocket socket) {
 *  }
 *
 *  }
 */
abstract class Synthesiser
{
  /**
   * Performs synthesises on the given code producing code results.
   */
  Future<SynthesiseResult> synthesise(String code);
}

class SynthesiseResult
{
  final List<String> results;

  final String requestId;

  SynthesiseResult(this.results, this.requestId);
}