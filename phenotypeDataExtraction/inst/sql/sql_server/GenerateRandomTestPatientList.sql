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

IF OBJECT_ID('@results.phenode_n', 'U') IS NOT NULL
  DROP TABLE @results.phenode_n;

CREATE TABLE @results.phenode_n (
  person_id INT,
  rnk INT
);

insert into @results.phenode_n (person_id,rnk)
select person_id,rnk from (
        SELECT DISTINCT person_id, DENSE_RANK() OVER (order by person_id) as rnk
          /* Enter appropriate OMOP data table name below*/
          FROM @cdm.person
          WHERE person_id NOT in (1 ) --TODO fix
  ) U
  /* Enter appropriate number of testing patients, n below.
   We have used 30,000 in our experiments and hence have retained that number here */
  WHERE rnk <=30000
  order by rnk
;
