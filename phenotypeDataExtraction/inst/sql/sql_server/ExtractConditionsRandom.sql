/*********************************************************************************
# Copyright 2014-2015 Observational Health Data Sciences and Informatics
#
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
********************************************************************************/

-- Place parameterized SQL statements in this file

{DEFAULT @cdm = 'cdm'}
{DEFAULT @results = 'results'}


SELECT DISTINCT person_id
      ,condition_concept_id
  /* Enter appropriate OMOP data table name below*/
  FROM @cdm.condition_occurrence
  WHERE
    person_id in( select person_id from @results.phenode_n)
  /* Insert list of test patients in the following format for n test patients*/
  /*'MRNt1','MRNt2',...'MRNtn'*/

  --AND person_id NOT in (1)
  /* Insert list of seed patients in the following format for m seed patients*/
  /*'MRNs1','MRNs2',...'MRNsm'*/

;


