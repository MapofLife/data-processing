#postprocess
def divide_namelist_by_attribute(full,attribute): #assumes first column has names and may be mixed with references. Uses capital letters and a reference attribute to divide references itno a separate column.
    final=''
    for x in range(0,len(full)):
        findname=full[x].rsplit(' ')
        if len(findname)>1 and findname[0][0].isupper():
            base=findname[0]
            addon='\t'
            for y in range(1,len(findname)):
                if findname[y]!='':
                    if y<len(findname) and y<4 and attribute not in findname[y] and not(findname[y][0].isupper()):
                        base=base+' '+findname[y]
                    else:
                        addon=addon+' '+findname[y]
                else:
                    pass
            print(base+addon)
            final=final+base+addon+'\n'
        else:
            print(full[x])
            final=final+full[x]+'\n'
    return final

def moveword(full,word,column1): #column initially should start count at 1; converted in script. Moves from col1 to beginning of next column.
    final=''
    col1=column1-1
    for x in range(0,len(full)):
        findcol=full[x].rsplit('\t')
        col1split=findcol[col1].rsplit(' ')
        base=''
        for r in range(0,col1): #form base
            base=base+findcol[r]
        addon=''
        for q in range(col1+1,len(findcol)):    #form addon
            addon=addon+findcol[q]
        part1=''
        part2=''
        switch=0
        for y in range(0,len(col1split)):    #form part1 and part2
            if col1split[y]!=word and switch==0:
                part1=part1+col1split[y]
            elif col1split[y]==word and switch==0:
                part2=part2+col1split[y]
                switch=1
            else:
                part2=part2+col1split[y]
        print(base+part1+'\t'+part2+' '+addon)
        final=final+base+addon+'\n'
    return final
        

def column_name_reversal(full, column, marker, colname): #full is filename, column is the column number counting up from 1, marker is whatever marks the spot (such as Yes, or X), colname is the of the old column and the name propogated throughout the appended column.
    final=''
    col=column-1
    for x in range(0,len(full)):
        base=full[x]
        addon='\t'
        findcol=full[x].rsplit('\t')
        if findcol[col]==marker:
            addon=addon+colname
        else:
            pass
        print(base+addon)
        final=final+base+addon+'\n'
    return final
        

def expandtitles_include(full,endattribute,linereturns): #expands a single word into every subsequent column until running into the next name. Works based off of endattribute, the suffix of whatever the column might be. LInereturns is \t, \n, ' ' as the case may be. Record this to get rid of it.
    final=''
    base=''
    for x in range(0,len(full)):
        if endattribute==full[x][len(full[x])-len(endattribute):len(full[x])]: #if suffix matches perfectly...
            base=full[x].rstrip(linereturns)
        else:
            print(base+'\t'+full[x])
            final=final+base+'\t'+full[x]
    return final
            
def expandtitles_exclude(full,attribute,linereturns): #expands fields unless they contain a particular attribute
    final=''
    base=''
    for x in range(0,len(full)):
        if len(full[x].rsplit(' '))==2 and attribute not in full[x]:
            base=full[x].rstrip(linereturns)
        else:
            print(base+'\t'+full[x])
            final=final+base+'\t'+full[x]+'\n'
    return final

def single_column_combine(full,attribute): #combines the first column with the second given that the second contains a particular attribute
    final=''
    for x in range(0,len(full)):
        base=''
        add=''
        check=full[x].rsplit('\t')
        if len(check)>1:
            if attribute in check[1]:
                base=check[0]+' '+check[1]
            else:
                base=check[0]+'\t'+check[1]
        else:
            base=check[0]
        for r in range(2,len(check)):
            add=add+'\t'+check[r]
        print(base+'\t'+add)
        final=final+base+add+'\n'
    return final
        

def duplicate_to_csv_last_col(full, column): #Assumes CSV is the last of the columns
    final=''
    col=column-1
    for x in range(0,len(full)):
        tabsplit=full[x].rsplit('\t')
        colsplit=tabsplit[col].rsplit(',')
        if len(colsplit)>1:
#            colsplit[0]=colsplit[0][len(colsplit[0])-1]
            colsplit[len(colsplit)-1]=colsplit[len(colsplit)-1].rstrip('\n')
        else:
            colsplit[0]=colsplit[0].rstrip('\n')
        baseline=''
        for y in range(0,len(tabsplit)-1):
            baseline=baseline+tabsplit[y]+'\t'
        for r in range(0,len(colsplit)):
            print(baseline+colsplit[r])
            final=final+baseline+colsplit[r]+'\n'
    return final

def check_scientificname(array):
    problems=[]
    import re
    for x in range(1,len(array)):
        if (re.search('^[A-Z][a-zA-Z]+$',array[x][0].rsplit(' ')[0]) is not None) and (re.search('^[a-z]+$',array[x][0].rsplit(' ')[1]) is not None):
            pass
        else:
            problems.append(array[x])
    return problems
    
