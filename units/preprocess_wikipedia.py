# code for preparing Wikistats data
# code below adds the filename (containing date-time information) to each row of the data files

# See http://stackoverflow.com/questions/29686573/spark-obtaining-file-name-in-rdds.

# invocation of pySpark:
# need driver memory set or get Java heap out of memory
# pyspark --master $SPARK_URL --driver-memory 25G 

# Using multiple nodes results in Spark errors so use single node.
# This processing may only use a couple cores -- this seems to be because sc.wholeTextFiles only puts the files into two partitions - not clear why, and setting minPartitions greater than 2 also results in Spark errors.

# include these next two lines if running via spark-submit rather
# than interactively via pyspark:
# from pyspark import SparkContext
# sc = SparkContext()

dir = '/global/scratch/paciorek/wikistats'

files = sc.wholeTextFiles(dir + '/' + 'raw')

# files.count()  # ~2k files
# files.getNumPartitions()  # 2

def makeLines(file):
    name = file[0].split('/')
    name = name[-1].split('-')[1:3]
    name[1] = name[1][:-3]
    entries = file[1].split('\n')
    out = [name[0] + ' ' + name[1] + ' ' + tmp for tmp in entries]
    return(out)

# flatMap takes RDD where each record is a file and creates a record for each row in each file
lines = files.flatMap(makeLines)
# lines.count()  

# repartition so that have data spread across more than two output files
# for more efficient input in later steps of analysis
# use a large number of partitions so that can read files into R
# in parallel without going over 64 GB RAM limit of Savio node
lines.repartition(960).saveAsTextFile(dir + '/' + 'dated')

# errors if save out as gzipped:
# lines.repartition(480).saveAsTextFile(dir + '/' + 'dated', "org.apache.hadoop.io.compress.GzipCodec")

