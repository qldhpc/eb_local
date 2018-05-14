import os
import re

def myreadlines(f, newline):
	buf = ""
	while True:
		while newline in buf:
			pos = buf.index(newline)
			yield buf[:pos]
			buf = buf[pos + len(newline):]
		chunk = f.read(4096)
		if not chunk:
			yield buf
			break
		buf += chunk

webIndex='available_packages_by_name.html'
webCRAN='https://cran.r-project.org'
cranPackages='./CRAN-packages'
if not os.access('./'+cranPackages,os.R_OK):
	cP = open(cranPackages,'w+');

	if not os.access('./'+webIndex,os.R_OK):
		os.system('wget -q '+webCRAN+'/web/packages/'+webIndex+' >/dev/null');
	try:
		with open(webIndex,'r') as wI:
			i=0
			for line in myreadlines(wI,'<tr>'):
				if line.find("/web/") != -1:
					pName=line.split('/')[4]
					pDesc=(re.split('\<\/td\>|\n',line))
					pDesc1=pDesc[2][4:]+' '+re.split('<\/tr>',pDesc[3])[0]
					pVersion='0.0.0'
					try:
						os.system('wget -q -O ./r-pack/'+pName+'.html '+webCRAN+'/web/packages/'+pName+'/index.html')
						with open('./r-pack/'+pName+'.html','r') as pN:
							for v in myreadlines(pN,'<tr>'):
								if v.find("Version:") != -1:
									pVersion=re.split('[</td>]|\n|[<td>]',v)[15]
						pN.close();
						os.system('rm ./r-pack/'+pName+'.html')
					except:
						print "Couldn't get the version information for "+pName
					output=pName+','+pVersion+','+pDesc1
					cP.write(output+'\n')
	except:
		print "Error!! not really a helpful message"
	cP.close()

cP = open(cranPackages,'r')
eb_rlibs=open('./rlibs_auto',w)
eb_rlibs.write('\
		\
		\
		\
		\
		\

		\
		
		\
				')

for line in cP:

