from preprocess import *
from process import *
import re
import sys
import os

#make '' into none
def empty_to_None(array):
    final=[]
    for x in range(0,len(array)):
        if array[x]=='':
            final.append(None)
        else:
            final.append(array[x])
    return final

def make_propername(name):
    final=''
    if '-' in name:
        temp=name.rsplit('-')
        for x in range(len(temp)):
            final=final+temp[x].capitalize()+'-'
        final=final[0:(len(final)-1)]
    elif ', ' in name:
        temp=name.rsplit(', ')
        for x in range(len(temp)):
            final=final+temp[x].capitalize()+', '
        final=final[0:(len(final)-2)]
    else:
        final=name.capitalize()
    return final
    
def make_short_url(full_url):
    final=''
    temp=full_url.rsplit('/')
    if 'http' in temp[0] or 'ftp' in temp[0]:
        final=temp[2]
    else:
        final=temp[0]
    return final

#b is an array
#make a dictionary out of b
def makedict(array):
    arraydict={'%tax_class%':array[1],'%provider%':array[2],'%contact%':array[3],'%coverage%':array[4],'%dataset_id%':array[5],'%date_more%':array[6],'%date_range%':array[7],'%title%':array[8],'%recommended_citation%':array[9],'%seasonality%':array[10],'%seasonality_more%':array[11],'%spatial_metadata%':array[12],'%taxon%':array[13],'%taxonomy_metadata%':array[14],'%full_url%':array[15],'%cap_provider%':make_propername(array[2]),'%short_url%':make_short_url(array[15]),'%cap_tax_class%':make_propername(array[1]),'%pub_year%':(array[16])}
    return arraydict
    
#turn dictionary into sql query and save that string

def make_surfacing_tables(fielddict,templatename):
    #imported the whole file with getfile and pasted it here
    surfacing_tables_raw=getfile(templatename)
    #find and replace using dictionary
    surfacing_tables_tmp=''
    for line in surfacing_tables_raw:
        pattern = re.compile('|'.join(fielddict.keys()))
        surfacing_tables_tmp = surfacing_tables_tmp + pattern.sub(lambda x: fielddict[x.group()], line)
    #take out '', and turn it into null
        surfacing_tables=surfacing_tables_tmp.replace("\t'', --","\tnull, --")
    return surfacing_tables

def make_basic_tables(fielddict,templatename):
    basic_tables_raw=getfile(templatename)
    basic_tables_tmp=''
    for line in basic_tables_raw:
        pattern = re.compile('|'.join(fielddict.keys()))
        basic_tables_tmp = basic_tables_tmp + pattern.sub(lambda x: fielddict[x.group()], line)
        basic_tables=basic_tables_tmp.replace("\t'', --","\tnull, --")
    return basic_tables

def do_all(variable,filename):
    if variable=='surfacing':
        a=getcsv_array_commas(filename)
        b=get_column(a,2)
        c=empty_to_None(b)
        d=makedict(c)
        e=make_surfacing_tables(d,'template_surfacing_tables.sql')
        print(e)
    elif variable=='basic':
        a=getcsv_array_commas(filename)
        b=get_column(a,2)
        c=empty_to_None(b)
        d=makedict(c)
        f=make_basic_tables(d,'template.sql')
        print(f)

import sys
if __name__ == '__main__':
    if len(sys.argv)==3:
        do_all(sys.argv[2], sys.argv[1])
    else:
        print('Please enter in the format python3 script.py [filename] [basic or surfacing] >[savename]')
else:
    print('Please enter in the format python3 script.py [filename] [basic or surfacing] >[savename]')
