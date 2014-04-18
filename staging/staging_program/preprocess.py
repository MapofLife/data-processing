#preprocess
#-----------------------------------------------
import sys
import os
import csv
#-----------------------------------------------
def getfile(filename): # get the file in its regular form
    path=os.getcwd()
    all=open(path+'/'+filename,"r")
    all.seek(0)
    full=all.readlines()
    return full
#----------------------------------------------
def getcsv_array(filename):
    import csv
    array=[]
    with open(filename, newline='') as csvfile:
    	readthis=csv.reader(csvfile, delimiter='\t')
    	for row in readthis:
    		array.append(row)
    return array
#---------------------------------------------
def getcsv_array_commas(filename):
    import csv
    array=[]
    with open(filename, newline='') as csvfile:
    	readthis=csv.reader(csvfile, delimiter=',')
    	for row in readthis:
    		array.append(row)
    return array
#---------------------------------------------
def getcsv_dict(filename,numcol):#name of the file and number of columns
    import csv
    d={}
    for x in range(0,numcol):#make appropriate number of columns
          exec(eval('"col"+eval("str(x)")')+'='+'"'+'Column'+str(eval('x'))+'"')
          tmp=eval('"d.update({"+"col"+eval("str(x)")+":[]})"')
          exec(tmp) #puts in dictionary as empty list
          with open(filename, newline='') as csvfile:
              readthis=csv.reader(csvfile, delimiter='\t')
              for row in readthis:
                  eval('d[col'+str(x)+'].append(row['+str(x)+'])')
    return d
        