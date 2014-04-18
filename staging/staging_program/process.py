#process

def remove_empty_rows(array):
    mid=[]
    for y in range(0,len(array)):#get rid of empties
        if array[y]==[]:
            pass
        else:
            mid.append(array[y])
    return mid

def remove_empty_string_array(array):
    final=[]
    for x in range(0,len(array)):
        if array[x]=='':
            pass
        else:
            final.append(array[x])
    return final

def remove_num(full): #remove numbers from the file
    nonum=[]
    for r in range(0,len(full)):
        x=full[r]
        q=''
        for y in range(0,len(x)):
            if x[y].isdigit()==True:
                q=q
            else:
                q=q+x[y]
        nonum.append(q)
    return nonum

def remove_num_field(full): #removes fields that contain numbers from the file
    nonum=[]
    for x in range(0,len(full)):
        truefalse=0
        for y in range(0,len(full[x])):
            if full[x][y].isdigit():
                truefalse=1
            else:
                pass
        if truefalse==0:
            nonum.append(full[x])
    return nonum

#this doesn't work-- removes too much
#def remove_numeric_field_array(array): #if there is a number literally anywhere in the array the whole row is gone
#    import re
#    final=[]
#    for x in range(0,len(array)):
#        truefalse=0
#        for y in range(0,len(array[x])):
#            for z in range(0,len(array[x][y])):
#                if not(re.search(r"[A-za-z ]+", array[x][y][z])):
#                    truefalse=1
#                else:
#                    pass
#        if truefalse==0:
#            final.append(array[x])
#    return final

def remove_field_by_attribute_array(array,attribute): #if there is a particular string literally anywhere in the array the whole row is gone
    import re
    final=[]
    for x in range(0,len(array)):
        truefalse=0
        for y in range(0,len(array[x])):
            if eval('re.search(r"('+attribute+')", array[x][y])'):
                truefalse=1
            else:
                pass
        if truefalse==0:
            final.append(array[x])
    return final

def remove_all_caps(full): # removes all caps entries
    nocaps=[]
    for r in range(0,len(full)):
        if full[r].isupper() and len(full[r].rsplit(' '))==1:
            pass
        else:
            nocaps.append(full[r])
    return nocaps

def remove_words(full, words): #remove particular word(s) from the file
    noword=[]
    for r in range(0,len(full)):
        x=full[r]
        if words not in full[r]:
            noword.append(x)
        else:
            pass
    return noword

def remove_words_exclusive(full,words): #removes words exactly
    noword=[]
    for x in range(0,len(full)):
        if full[x]==words:
            pass
        else:
            noword.append(full[x])
    return noword

def remove_returns(full): #remove entries that are just \n spaces from the file
    noreturns=[]
    for r in range(0,len(full)):
        x=full[r]
        if x=='\n':
            pass
        elif x==' \n':
            pass
        else:
            noreturns.append(x)
    return noreturns

def bite_returns(full):
    array=[]
    for x in range(0,len(full)):
        array.append(full[x].rstrip('\n'))
    return array

def bite_spaces_csv(array):
    final=[]
    for x in range(0,len(array)):
        line=[]
        for y in range(0,len(array[x])):
            line.append(array[x][y].rstrip(' '))
        final.append(line)
    return final
    

def remove_uppers(full): #removes all caps fields:
    lower=[]
    for r in range(0,len(full)):
        x=full[r]
        if x.isupper()==False:
            lower.append(x)
        else:
            pass
    return lower

def remove_single(full): #removes fields that have only one word in them
    new=[]
    for r in range(0,len(full)):
        x=full[r]
        newstr=x.replace(' \n','')
        if ' ' in newstr:
            new.append(x)
        else:
            pass
    return new

def remove_min_csv(array,min):#removes any list that has fewer than min entries
    new=[]
    for r in range(0,len(array)):
        if len(array[r])<=min:
            pass
        else:
            new.append(array[r])
    return new

def split_names_csv(array):
    final=[]
    for x in range(0,len(array)):
        line=[]
        check=array[x][0].rsplit(' ')
        if len(check)>1:
            line.append(check[0]+' '+check[1])#append name, which should be first two
            string=''
            for r in range(2,len(check)):#append the rest
                if check[r]!='':
                    string=string+check[r]+' '
                else:
                    pass
            string=string.rstrip(' ')
            line.append(string)
            for y in range(1,len(array[x])):
                line.append(array[x][y])
        else:#otherwise it must be a title
            line.append(check[0])
        final.append(line)
    return final

def populate_titles_csv(array):#populates with a title that has nothing next to it; literally a title
    final=[]
    namenum=[]
    r=0
    while r<len(array):#make an index of the title coordinates
        if len(array[r])==1:
            namenum.append(r)
            r=r+1
        else:
            r=r+1
    for y in range(0,len(namenum)):#populate the final array with titles in a new first column
        title=[]
        title.append(array[namenum[y]][0])
        if y==(len(namenum)-1):
            for q in range((namenum[y]+1),len(array)):
                line=title+array[q]
                final.append(line)
        else:
            for w in range((namenum[y]+1),(namenum[y+1])):
                line=title+array[w]
                final.append(line)
    for i in range(0,len(final)):#finally, remove the titles from the final array
        if len(final[i])==1:
            del(final[i])
        else:
            pass
    return final

def delete_titles(array,num_col):#deletes all rows that have a particular number of titles. count number of columns. If there are 2, put 2. if 1, put 1 for num_col.
    final=[]
    for x in range(0,len(array)):
        if len(array)==(num_col-1) or (len(array[x])-array[x].count(''))==(num_col):
            pass
        else:
            final.append(array[x])
    return final

def delete_titles_by_attribute(array,attribute,column):#deteles all rows that have a particular string in the indicated column (if it is the 4th column write 4)
    final=[]
    for x in range(0,len(array)):
        if attribute in array[x][column-1]:
            pass
        else:
            final.append(array[x])
    return final

def delete_titles_by_wordcount(array, wordcount, column): #deletes all rows that have the indicated number of words in the indicated column (if it is the 2nd column write 2, etc)
    final=[]
    for x in range(0,len(array)):
        if len(array[x][column-1].rsplit(' '))==wordcount:
            pass
        else:
            final.append(array[x])
    return final

#the following needs to be alatered to be more versatile
def expand_distribution_encounter(array,startdists,enddists,namedict,marker):#startdists: first column that has distribution, counting up from 1. enddists: last column that has distribution. namedict: dictionary with {position:'area',position:'area',etc} where position coordinate also counts up from 1. Marker represents the blank space such as '' or 0.
    final=[]
    start=startdists-1
    end=enddists
    maximum=end-start
    for x in range(0,len(array)):
        fieldnum=[w+start for w in [i for i,e in enumerate(array[x][start:end]) if e!=marker]]
        for q in range(0,(maximum-array[x][start:end].count(marker))):
            dist=namedict[fieldnum[q]+1]
            final.append(array[x]+[dist]+[array[x][fieldnum[q]]])
    return final

def expand_distribution_encounter_csvdist(array,distcolumn):#expands the distribution in a certain column where everything in the column is listed in CSV form.
    import re
    final=[]
    distcol=distcolumn-1
    for x in range(0,len(array)):
        dists=re.sub(r'\s+','',array[x][distcol]).rsplit(',')
        for q in range(0,len(dists)):
            final.append(array[x]+[dists[q]])
    return final

def breaks_to_spaces_csv(array):#changes \n to ' ' in a csv imported with getcsv_array()
    final=[]
    for x in range(0,len(array)):
        line=[]
        for y in range(0,len(array[x])):
            entry=array[x][y]
            if '\n' in entry:
                entry=entry.replace('\n',' ')
            line.append(entry)
        final.append(line)
    return final

def get_column(array,colnum):#colnum is number starting from 1 of column
    final=[]
    for x in range(0,len(array)):
        final.append(array[x][colnum-1])
    return final

def savecsv(filename,delimiter_to_use,array):
    import csv
    with open(filename, 'w', newline='') as csvfile:
        writethis=csv.writer(csvfile, delimiter=delimiter_to_use)
        for x in range(0,len(array)):
            writethis.writerow(array[x])
    
def savestr(filename,string):
    with open(filename, 'wt') as filesave:
        for x in range(0,len(string)):
            filesave.write(string[x])
