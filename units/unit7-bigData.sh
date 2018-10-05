############################################################
### Demo code for Unit 7 of Stat243, "Databases and Big Data"
### Chris Paciorek, October 2018
############################################################

#####################################################
# 6: Hadoop, MapReduce, and Spark
#####################################################

### 6.3.3 Storing data for use in Spark

## @knitr hdfs

## DO NOT RUN THIS CODE ON SAVIO ##
## data for Spark on Savio is stored in scratch ##

hadoop fs -ls /
hadoop fs -ls /user
hadoop fs -mkdir /user/paciorek/data
hadoop fs -mkdir /user/paciorek/data/wikistats
hadoop fs -mkdir /user/paciorek/data/wikistats/raw
hadoop fs -mkdir /user/paciorek/data/wikistats/dated

hadoop fs -copyFromLocal /global/scratch/paciorek/wikistats/raw/* \
       /user/paciorek/data/wikistats/raw

# check files on the HDFS, e.g.:
hadoop fs -ls /user/paciorek/data/wikistats/raw

## now do some processing with Spark, e.g., preprocess.{sh,py}

# after processing can retrieve data from HDFS as needed
hadoop fs -copyToLocal /user/paciorek/data/wikistats/dated .

## @knitr null

## 6.3.4 Using Spark on Savio

## @knitr savio-spark-setup

tmux new -s spark  ## to get back in if disconnected: tmux a -t spark

## having some trouble with ic_stat243 and 4 nodes; check again
srun -A ic_stat243 -p savio2 --nodes=4 -t 1:00:00 --pty bash
module load java spark/2.1.0 python/3.5
source /global/home/groups/allhands/bin/spark_helper.sh
spark-start
## note the environment variables created
env | grep SPARK


spark-submit --master $SPARK_URL  $SPARK_DIR/examples/src/main/python/pi.py

## @knitr pyspark-start

# PySpark using Python 3.5 (Spark 2.1.0 doesn't support Python 3.6)
# HASHSEED business has to do ensuring consistency across Python sessions
pyspark --master $SPARK_URL --conf "spark.executorEnv.PYTHONHASHSEED=321"  --executor-memory 60G 


## @knitr savio-spark-setup-updated-python

# might need to set these variables for all Python packages to work
pyspark --master $SPARK_URL --executor-memory 60G \
        --conf "spark.executorEnv.PATH=${PATH}" \
        --conf "spark.executorEnv.LD_LIBRARY_PATH=${LD_LIBRARY_PATH}" \
        --conf "spark.executorEnv.PYTHONPATH=${PYTHONPATH}" \
        --conf "spark.executorEnv.PYTHONHASHSEED=321"


## 6.3.14 sparklyr example

## @knitr savio-sparklyr-setup

module load r r-packages

R
