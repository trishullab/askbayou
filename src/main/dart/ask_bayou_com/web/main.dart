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

import 'package:askbayoucom/controller.dart';
import 'package:askbayoucom/model_result_quality_feedback.dart';
import 'package:dart_config/default_browser.dart';
import 'package:askbayoucom/model_api_synthesis.dart';

void main()
{
  /**
   * Load config.yaml and start application.
   */
  loadConfig().then((Map config)
  {
    // config.yaml load was success

    /*
     * Determine what endpoint should be used for making apy synthesis calls.
     *
     * First check if an endpoint was explicitly specified via url. If not look in config.yaml.
     */
    String apiSynthesisEndpoint;
    {
      String endpointKey = "apiSynthesisEndpoint";
      if(Uri.base.queryParameters != null && Uri.base.queryParameters.containsKey(endpointKey))
      {
        apiSynthesisEndpoint = Uri.base.queryParameters[endpointKey];
      }
      else
      {
        apiSynthesisEndpoint = config[endpointKey];
      }
    }

    /**
     * Todo: doc
     */
    String apiSynthesisFeedbackEndpoint;
    {
      String endpointKey = "apiSynthesisFeedbackEndpoint";
      if(Uri.base.queryParameters != null && Uri.base.queryParameters.containsKey(endpointKey))
      {
        apiSynthesisFeedbackEndpoint = Uri.base.queryParameters[endpointKey];
      }
      else
      {
        apiSynthesisFeedbackEndpoint = config[endpointKey];
      }
    }

    /*
     * Start app.
     */
    new AppController(new SynthesiserHttp(apiSynthesisEndpoint),
                          new ResultQualityFeedbackRepositoryHttp(apiSynthesisFeedbackEndpoint)).start();
  },
  onError: (error)
  {
    // config.yaml load failed
    print(error);
    new AppController(new SynthesiserDoNothing(), new ResultQualityFeedbackRepositoryDoNothing())
        .start("Unable to load configuration file.  Please retry.");
  });

}
