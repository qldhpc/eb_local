#!/bin/bash
# ----------------------------------------------------------------------------
#
#   Installer for Mathematica Applications
#
#   This file and all scripts and messages accessed from this file
#        (c) 2004 Wolfram Research, Inc. All rights reserved.
#
#

LANG=C
export LANG

# ----------------------------------------------------------------------------
# Function: BuildDesktopFile()

BuildDesktopFile() {
	if [ "${DEBUG}" = "true" ]; then
      		echo "<< ### Function: BuildDesktopFile() ### >>"
      		echo "<< ### Function: BuildDesktopFile() ### >>" 1>&2
   	fi

	#### xdg default values
	major_version_number=`echo ${VersionNumber} | sed -e 's|\.[0-9]*||'`
	a=application
	e=all

	file_name="wolfram-mathematica${major_version_number}.desktop"
	i=wolfram-mathematica
	m=x-scheme-handler/wolfram\+cloudobject\;x-scheme-handler/wolframmathematica\+cloudobject
	menu_name=`echo ${FullProductName} ${major_version_number} | sed -e "s|^Wolfram ||"`
	t=${FullTargetDirectory}/Executables/Mathematica

	if [ "${InstallerType}" = "CBM" ]; then

e=cbm
file_name="wolfram-${e}1.desktop"

cat > "${xdgScripts}/${file_name}" << EOF
[Desktop Entry]
Encoding=UTF-8
Version=2.0
Name=${ExecScriptsList}
Exec=${FullTargetDirectory}/FrontEnd/Palettes/'${ExecScriptsList}'
Terminal=false
Icon=application-vnd.wolfram.cbm
Type=Application
Comment=Technical Computing System
EOF

cat > "${xdgScripts}/wolfram-cbm.directory" << EOF
[Desktop Entry]
Version=1.0
Type=Directory
Name=Computer Based Math
Icon=application-vnd.wolfram.cbm
EOF

	### Wolfram CDF Player
	elif [ "${InstallerType}" = "CDF" ]; then  

		e=cdf
		file_name="wolfram-${e}${major_version_number}.desktop"
		menu_name=`echo ${FullProductName} ${major_version_number}`
		i=wolfram-player
		t=${FullTargetDirectory}/Executables/WolframCDFPlayer

cat > "${xdgScripts}/wolfram-${e}.directory" << EOF
[Desktop Entry]
Version=1.0
Type=Directory
Name=Wolfram CDF Player 
Icon=wolfram-player

EOF

	### Wolfram Desktop
	elif [ "${InstallerType}" = "WD" ]; then

		e=wd
		menu_name=`echo ${FullProductName} ${major_version_number}`
		file_name="wolfram-${e}${major_version_number}.desktop"
		i=wolfram-${e}
		m=x-scheme-handler/wolfram\+cloudobject\;x-scheme-handler/wolframdesktop\+cloudobject
		t=${FullTargetDirectory}/Executables/WolframDesktop

cat > "${xdgScripts}/wolfram-${e}.directory" << EOF
[Desktop Entry]
Version=1.0
Type=Directory
Name=Wolfram Desktop 
Icon=wolfram-${e}

EOF

	### Wolfram ProgrammingLab
	elif [ "${InstallerType}" = "WPL" ]; then

		e=wpl
		menu_name=`echo ${FullProductName} ${major_version_number}`
		file_name="wolfram-${e}${major_version_number}.desktop"
		i=wolfram-${e}
		m=x-scheme-handler/wolfram\+cloudobject\;x-scheme-handler/wolframproglab\+cloudobject
		t=${FullTargetDirectory}/Executables/WolframProgrammingLab

cat > "${xdgScripts}/wolfram-${e}.directory" << EOF
[Desktop Entry]
Version=1.0
Type=Directory
Name=Wolfram Programming Lab
Icon=wolfram-${e}

EOF

	elif [ "${InstallerType}" = "WSM" ]; then

		e=wsm
		file_name="wolfram-${e}${major_version_number}.desktop"
		i=wolfram-systemmodeler
		mime_type=${a}/vnd.wolfram.mo\;${a}/vnd.wolfram.moe\;${a}/vnd.wolfram.sme\;${a}/vnd.wolfram.sma
		t=${FullTargetDirectory}/bin/ModelCenter

cat > "${xdgScripts}/wolfram-${e}.directory" << EOF
[Desktop Entry]
Version=1.0
Type=Directory
Name=Wolfram SystemModeler
Icon=wolfram-systemmodeler
EOF

cat > "${xdgScripts}/${file_name}" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=${menu_name}
Comment=Technical Computing System
TryExec=${t}
Exec=${t} %F
Icon=${i}
MimeType=${mime_type};
EOF

	fi

	if [ "${InstallerType}" != "CBM" ] && 
		[ "${InstallerType}" != "WSM" ]; then

		# mime type entries.  
		mime_type=${a}/mathematica\;${a}/x-mathematica\;${a}/vnd.wolfram.nb\;${a}/vnd.wolfram.cdf\;
		mime_type=${mime_type}${a}/vnd.wolfram.player\;${a}/vnd.wolfram.mathematica.package\;${a}/vnd.wolfram.wl\;

cat > "${xdgScripts}/${file_name}" << EOF 
[Desktop Entry]
Version=1.0
Type=Application
Name=${menu_name}
Comment=Technical Computing System
TryExec=${t}
Exec=${t} %F
Icon=${i}
MimeType=${mime_type}${m};
EOF
	fi

	if [ -f "${xdgScripts}/xdg-desktop-menu" ]; then
		${xdgScripts}/xdg-desktop-menu install ${xdgScripts}/wolfram-${e}.directory ${xdgScripts}/${file_name}

		# Ubuntu-specific fix to deal with launchpad bug 592671
		if [ "${isRoot}" = "true" ]; then
			if [ -f /usr/share/applications/desktop.*.cache ]; then
				rm -f /usr/share/applications/desktop.*.cache > /dev/null 2>&1
				update-desktop-database > /dev/null 2>&1
				if [ -f /usr/bin/gnome-panel ]; then
					killall gnome-panel > /dev/null 2>&1
				fi
			fi
		fi
	fi

	if [ "${DEBUG}" = "true" ]; then
		echo "<< ### Exiting Function: BuildDesktopFile() ### >>"
		echo "<< ### Exiting Function: BuildDesktopFile() ### >>" 1>&2
	fi

}


# ----------------------------------------------------------------------------
# Function: CheckSELinux_()

# If we are running Linux or Linux-x86-64, check selinux settings.
CheckSELinux_() {
	if [ "${DEBUG}" = "true" ]; then
		echo "<< ### Function: CheckSELinux_() ### >>"
		echo "<< ### Function: CheckSELinux_() ### >>" 1>&2
	fi

	if [ "${DefaultSystemID}" = "Linux" \
   		-o "${DefaultSystemID}" = "Linux-x86-64" ]; then
		# If selinuxenabled returns with 0 status it is enabled.
		SELinuxEnabled=`selinuxenabled 2>/dev/null;echo ${?}`
		if [ -d "${FullTargetDirectory}/SystemFiles/Libraries"  \
			-a "${SELinuxEnabled}" = "0" ]; then

			if [ "${Automatic}" = "false" ]; then
				SELinux=""
			elif [ "${SELinux}" = "y" -o "${SELinux}" = "Y" ]; then
				SELinux="y"
			elif [ "${SELinux}" = "n" -o "${SELinux}" = "N" ]; then
				SELinux="n"
			else
				PrintCopyText Error "BadSELinuxAutomaticError"
				SELinux="n"
			fi

			PrintCopyText Text "SELinuxText"
			PrintCopyText Prompt "SELinuxPrompt"
			if [ "${Automatic}" = "true" ]; then
				echo "${SELinux}"
			fi
			while [ "${SELinux}" != "y" -a "${SELinux}" != "n" ]; do
				read SELinux
				if [ "${SELinux}" = "y" -o "${SELinux}" = "Y" ]; then
					SELinux="y"
				elif [ "${SELinux}" = "n" -o "${SELinux}" = "N" ]; then
					SELinux="n"
				else
					PrintCopyText Error "BadSELinuxError"
					echo ""
					PrintCopyText Text "SELinuxText"
					PrintCopyText Prompt "SELinuxPrompt"
				fi
			done

			echo ""

			# Fix settings for the included Mathematica libraries.
			if [ "${SELinux}" = "y" ]; then
				chconFailure=`find "${FullTargetDirectory}" -name "*.so*" -exec chcon -t textrel_shlib_t {} \; 2>/dev/null;echo ${?}`
			fi
			if [ "${SELinux}" = "n" -o "${chconFailure}" != "0" ]; then
				PrintCopyText Error "ChconError"
				SELinux="n"
			fi
		fi
	fi

	if [ "${DEBUG}" = "true" ]; then
		echo "<< ### Exiting Function: CheckSELinux_() ### >>"
		echo "<< ### Exiting Function: CheckSELinux_() ### >>" 1>&2
	fi

}


# ----------------------------------------------------------------------------
# Function: CleanUp_()

# Trap any exit (0). Remove $InstallTempDir if it exists and check for
# errors in the $ErrorFile
CleanUp_() {
	if [ "${DEBUG}" = "true" ]; then
		echo "<< ### Function: CleanUp_() ### >>"
		echo "<< ### Function: CleanUp_() ### >>" 1>&2
	fi

	InstallErrors=`cat "${ErrorFile}" | grep -v '^$' | \
		grep -v 'decompression OK, trailing garbage ignored$' | \
		grep -v 'tar: Signal caught, cleaning up'`
	# Trapped sigint with no other errors, restore previous directory contents
	# if possible.
	if [ "${InstallErrors}" = "SIGINT" ]; then
		if [ "${Verbose}" = "true" ]; then
			PrintCopyText Verbose "RemoveLogSigintVerbose"
		fi
		rm -rf "${ErrorFile}"

		# If there is a backup directory, restore the previous files
		# if we received a sigint.
		if [ -n "${BackupDirBase}" ]; then

			if [ "${BackupComplete}" = "true" ]; then
				if [ "${Verbose}" = "true" ]; then
					PrintCopyText Verbose "RemovingInstalledFilesVerbose"
				fi

				for Dir in $InstallDir; do
					if [ "${Dir}" = "NoInstallDirSpecified" ]; then
						BackupDir="${TargetDirectory}/${BackupDirBase}"
					else
						BackupDir="${TargetDirectory}/${Dir}/${BackupDirBase}"
					fi
					if [ ! -d "${BackupDir}" ]; then
						continue
					fi
					FullTargetDirectory=`dirname "${BackupDir}"`

#               	cd "${FullTargetDirectory}"
#               	rm -rf `ls -a1 | grep -v '^\.$' | grep -v '^\.\.$' | \
#                  	grep -v "^${BackupDirBase}$" | sort` 
   
					FileName=`ls -a1 "${FullTargetDirectory}" | grep -v '^\.$' | \
						grep -v '^\.\.$' | grep -v "^${BackupDirBase}$" | \
							sort | sed '1p;d'`
					while [ -n "${FileName}" ]; do
						if [ "${Verbose}" = "true" ]; then
							PrintCopyText Verbose "RemovingFileVerbose"
						fi

						rm -rf "${FullTargetDirectory}/${FileName}"
						FileName=`ls -a1 "${FullTargetDirectory}" | grep -v '^\.$' | \
							grep -v '^\.\.$' | grep -v "^${BackupDirBase}$" | \
								sort | sed '1p;d'`
					done
				done
			fi

			for Dir in $InstallDir; do
				if [ "${Dir}" = "NoInstallDirSpecified" ]; then
					BackupDir="${TargetDirectory}/${BackupDirBase}"
				else
					BackupDir="${TargetDirectory}/${Dir}/${BackupDirBase}"
				fi

				if [ "${Verbose}" = "true" ]; then
					PrintCopyText Verbose "RestoringFilesFromBackupVerbose"
				fi
      
				if [ ! -d "${BackupDir}" ]; then
					continue
				fi
				FullTargetDirectory=`dirname "${BackupDir}"`

				FileName=`ls -a1 "${BackupDir}" | grep -v '^\.$' | \
					grep -v '^\.\.$' | sort | sed '1p;d'`
				while [ -n "${FileName}" ]; do
					if [ "${Verbose}" = "true" ]; then
						PrintCopyText Verbose "MovingFileVerbose"
					fi

					mv "${BackupDir}/${FileName}" "${FullTargetDirectory}/."
					FileName=`ls -a1 "${BackupDir}" | grep -v '^\.$' | \
						grep -v '^\.\.$' | sort | sed '1p;d'`
				done
				rmdir "${BackupDir}"
			done # for Dir
		fi # if BackupDirBase
      
		# Remove new profiles and restore if possible      
		cleanHome
      
		# No errors, if not running with -help and the user did not
		# abort installation then remove the ErrorLog, Backup directories,
		# and any man pages that existed previously.
	elif [ -z "${InstallErrors}" ]; then
		if [ "${Verbose}" = "true" ]; then
			PrintCopyText Verbose "RemoveLogNoErrorVerbose"
		fi
		rm -rf "${ErrorFile}"
		if [ "${Help}" = "false" -a "${userexit}" = "false" ]; then
			if [ -n "${BackupDirBase}" ]; then
				for Dir in $InstallDir; do
					if [ "${InstallDir}" = "NoInstallDirSpecified" ]; then
						BackupDir="${TargetDirectory}/${BackupDirBase}"
					else
						BackupDir="${TargetDirectory}/${Dir}/${BackupDirBase}"
					fi
					rm -rf "${BackupDir}"
				done
			fi
		fi

		if [ -n "${ManPageDirectory}" ]; then
			for ManPage in $ExistingManPages; do
				rm -f "${ManPageDirectory}/${ManPage}.old"
			done
		fi
      
		# Remove old profile
		preferenceList="${profileTarget} ${installDirs} ${installLast}"
	
		for Prefs in $preferenceList; do
			if [ -f "${Prefs}.old" ] && [ -w "${Prefs}.old" ]; then
				rm -f "${Prefs}.old"
			fi
		done
            
		PrintCopyText Text "InstallCompleteText"
	# Errors found
	else
		if [ -d "${TargetDirectory}" -a -w "${TargetDirectory}" ]; then
			if [ "${Verbose}" = "true" ]; then
				PrintCopyText Verbose "ErrorsFoundMovingLogVerbose"
			fi
			mv "${ErrorFile}" "${TargetDirectory}/InstallErrors"
			echo ""
			PrintCopyText Error "InstallFailedMovedMessageError"
		else
			if [ "${Verbose}" = "true" ]; then
				PrintCopyText Verbose "ErrorsFoundVerbose"
			fi
			echo ""
			PrintCopyText Error "InstallFailedNoMovedMessageError"
		fi
		if [ -n "${BackupDirBase}" ]; then
			for Dir in $InstallDir; do
				if [ "${Dir}" = "NoInstallDirSpecified" ]; then
					FullTargetDirectory="${TargetDirectory}"
				else
					FullTargetDirectory="${TargetDirectory}/${Dir}"
				fi
				BackupDir="${FullTargetDirectory}/${BackupDirBase}"
				if [ -d "${BackupDir}" ]; then
					PrintCopyText Error "BackupCopyError"
				fi
			done
		fi

		if [ -n "${ManPageDirectory}" ]; then
			for ManPage in $AllManPages; do
				rm -f "${ManPageDirectory}/${ManPage}"
			done
			for ManPage in $ExistingManPages; do
				mv -f "${ManPageDirectory}/${ManPage}.old" "${ManPageDirectory}/${ManPage}"
			done
		fi
      
		# Remove new profiles and restore if possible
		cleanHome
	  
	fi

	if [ -n "${InstallerLog}" \
		-a -d "${TargetDirectory}" -a -w "${TargetDirectory}" ]; then
		if [ "${Verbose}" = "true" ]; then
			PrintCopyText Verbose "MovingLogFileVerbose"
		fi
		mv "${InstallerLog}" "${TargetDirectory}/InstallerLog"
	fi

	if [ -d "${TargetDirectory}" -a -w "${TargetDirectory}" ]; then
		cd "${TargetDirectory}"
		for Dir in $InstallDir; do
			if [ "${Dir}" = "NoInstallDirSpecified" ]; then
				InstallTempDir="${InstallTempDirBase}"
			else
				InstallTempDir="${Dir}/${InstallTempDirBase}"
			fi
			if [ -d "${InstallTempDir}" ]; then
				if [ "${Verbose}" = "true" ]; then
					PrintCopyText Verbose "RemovingTempDirVerbose"
				fi
				rm -rf "${InstallTempDir}"
			fi
		done
	fi

	cd "${ExecutionDirectory}"
   
	if [ "${Verbose}" = "true" ]; then
		PrintCopyText Verbose "ExitingVerbose"
	fi

	if [ "${DEBUG}" = "true" ]; then
		echo "<< ### Exiting Function: CleanUp_() ### >>"
		echo "<< ### Exiting Function: CleanUp_() ### >>" 1>&2
	fi

}

# ----------------------------------------------------------------------------
# Function: CleanUpOnDirtyExit_()

# Trap SIGINT (2). Remove the error log & TargetDirectory before exiting.
CleanUpOnDirtyExit_() {
	if [ "${DEBUG}" = "true" ]; then
		echo "<< ### Function: CleanUpOnDirtyExit_() ### >>"
		echo "<< ### Function: CleanUpOnDirtyExit_() ### >>" 1>&2
	fi

	echo ""
	echo ""

	# If we are cleaning up after a sigint make a note in the
	# ErrorFile for CleanUp.
	if [ "${sigint}" != "false" ]; then
		InstallErrors=`cat "${ErrorFile}"`
		if [ -z "`echo \"${InstallErrors}\" | egrep '^SIGINT$'`" ]; then
			echo "SIGINT" 1>&2
		fi

		if [ "${Verbose}" = "true" ]; then
			PrintCopyText Verbose "SigintCleanupVerbose"
		fi
	fi

	# If we made the target directory and it exists remove it.
	if [ "${MakeTargetDirectory}" = "true" -a -n "${TargetDirectoryParent}" \
		-a -d "${NewTargetDirectoryBase}" ]; then
		if [ "${Verbose}" = "true" ]; then
			PrintCopyText Verbose "RemoveTargetDirVerbose"
		fi

		# Remove all directories and files that we have created.
		cd "${TargetDirectoryParent}"
		rm -rf "${NewTargetDirectoryBase}"
	fi

	# If we have added the InstallDirs to the target directory,
	# remove the InstallDirs we have added. 
	if [ -d "${TargetDirectory}" -a -n "${MadeInstallDir}" ]; then
		for Dir in $MadeInstallDir; do
			if [ -d "${Dir}" ]; then
				if [ "${Verbose}" = "true" ]; then
					PrintCopyText Verbose "RemovingInstallDirVerbose"
				fi
				cd "${TargetDirectory}"
				rm -rf "${TargetDirectory}/${Dir}"
			fi
		done
	fi

	if [ -n "${ExecScripts_}" ]; then
		if [ "${MakeExecDirectory}" = "true" \
			-a -n "${ExecDirectoryParent}" -a -d "${NewExecDirectoryBase}" ]; then
			if [ "${Verbose}" = "true" ]; then
				PrintCopyText Verbose "RemoveExecDirVerbose"
			fi
			cd "${ExecDirectoryParent}"
			rm -rf "${NewExecDirectoryBase}"
		elif [ -d "${ExecDirectory}" ]; then
			for Script in $CreatedScriptList; do
				if [ "${Verbose}" = "true" ]; then
					PrintCopyText Verbose "RemoveScriptsVerbose"
				fi
				rm -f "${ExecDirectory}/${Script}"
			done
			if [ "${ScriptAction}" = "Rename" ]; then
				if [ "${Verbose}" = "true" ]; then
					PrintCopyText Verbose "RestoreScriptsVerbose"
				fi
				for Script in $ExistingScriptList; do
					mv -f "${ExecDirectory}/${Script}${AppendToName_}" "${ExecDirectory}/${Script}"
				done
			fi
		fi
	fi

	# Restore previous man pages.
	if [ -n "${ManPageDirectory}" ]; then
		for ManPage in $AllManPages; do
			rm -f "${ManPageDirectory}/${ManPage}"
		done
		for ManPage in $ExistingManPages; do
			mv -f "${ManPageDirectory}/${ManPage}.old" "${ManPageDirectory}/${ManPage}"
		done
	fi
   
	# Remove the new preference, env variable and restore the prior if it exists
	cleanHome

#  	if [ -n "${ComponentTarget}" \
# 		-a "${ComponentTargetExists}" != "true" \
#			-a "${MakeTargetDirectory}" != "true" ]; then
#		if [ "${Verbose}" = "true" ]; then
# 			PrintCopyText Verbose "RemoveComponentDirVerbose"
#		fi
# 		rm -rf "${TargetDirectory}/${ComponentTarget}"
#	fi

	if [ "${DEBUG}" = "true" ]; then
		echo "<< ### Exiting Function: CleanUpOnDirtyExit_() ### >>"
		echo "<< ### Exiting Function: CleanUpOnDirtyExit_() ### >>" 1>&2
	fi

	exit

}

# ----------------------------------------------------------------------------
# Function: CheckDirectory_()

CheckDirectory_() {
	if [ "${DEBUG}" = "true" ]; then
		echo "<< ### Function: CheckDirectory_() ### >>"
		echo "<< ### Function: CheckDirectory_() ### >>" 1>&2
	fi

	Directory="${1}"
	if [ -z "${Directory}" ]; then
		echo "CRITICAL FAILURE: CheckDirectory_() Error"
		echo "  \$Directory not defined."
		echo "Critical Failure in CheckDirectory." 1>&2
		sigint="false"
		CleanUpOnDirtyExit_
	fi

	DirectoryOkay_="null"
	MakeDirectory_="null"
	MakeInstallDir_="null"
	ParentFound_="null"

	if [ -d "${Directory}" ]; then
		MakeDirectory_="false"

		if [ "${VarToSet}" = "TargetDirectory" ]; then
			MadeInstallDir=""
		fi

		# First verify that all target directories exist and are writable.
		for Dir in $InstallDir; do
			if [ "${Dir}" = "NoInstallDirSpecified" \
				-o "${VarToSet}" = "ExecDirectory" ]; then
				FullInstallDir="${Directory}"
			else
				FullInstallDir="${Directory}/${Dir}"
			fi

			if [ "${VarToSet}" = "TargetDirectory" \
				-a -w "${Directory}" -a ! -d "${FullInstallDir}" ]; then
				DirectoryList=`echo "${Dir}" | tr '/' ' '`
				CompositeDir=""
				for PartialDir in $DirectoryList; do
					CompositeDir="${CompositeDir}${PartialDir}/"
					if [ ! -d "${Directory}/${CompositeDir}" ]; then
						mkdir "${Directory}/${CompositeDir}" > /dev/null 2>&1
						if [ "${?}" != "0" ]; then
							DirectoryOkay_="false"
							ans="y"

							for MadeDir in $MadeInstallDir; do
								rmdir "${Directory}/${MadeDir}"
							done
							MadeInstallDir=""
							break
						else
							if [ -z "${MadeInstallDir}" ]; then
								MadeInstallDir="${CompositeDir}"
							else
								MadeInstallDir="${CompositeDir} ${MadeInstallDir}"
							fi
							DirectoryOkay_="true"
						fi # $?
					fi # -d CompositeDir
				done # PartialDir
			fi # $VarToSet = TargetDirectory

			if [ -w "${FullInstallDir}" -a "${DirectoryOkay_}" != "false" ]; then
				touch "${FullInstallDir}/thisisatest" > /dev/null 2>&1
				if [ "${?}" != "0" ]; then
					DirectoryOkay_="false"
					ans="y"

					for MadeDir in $MadeInstallDir; do
						rmdir "${Directory}/${MadeDir}"
					done
					MadeInstallDir=""
					break
				else
					rm "${FullInstallDir}/thisisatest"
					DirectoryOkay_="true"
				fi
			else
				DirectoryOkay_="false"
				ans="y"
			fi

			if [ "${VarToSet}" != "TargetDirectory" ]; then
				break
			fi
		done

		# Next determine what message to print.
		MsgToPrint="None"
		for Dir in $InstallDir; do
			if [ "${VarToSet}" != "TargetDirectory" ]; then
				break
			fi

			if [ "${Dir}" = "NoInstallDirSpecified" ]; then
				FullInstallDir="${Directory}"
			else
				FullInstallDir="${Directory}/${Dir}"
			fi

			if [ "${DirectoryOkay_}" = "true" \
				-a "${VarToSet}" = "TargetDirectory" ]; then

				CurrentInstallationDir="${FullInstallDir}"
				CurrentInstallation="${CurrentInstallationDir}/.Revision"
				CurrentInstallationCreationID="${CurrentInstallationDir}/.CreationID"
				CurrentInstallationInfo="${CurrentInstallationDir}/.info"
				CurrentInstallationManifest="${CurrentInstallationDir}/.install-manifest"
				VersionsMatch="null"
				case "${MsgToPrint}" in
					FilesExist)
						# This is the most generic message we can print.
						# If it is already selected break out of the loop.
						break;;
					ThankYouForUpgrading)
						if [ -f "${CurrentInstallationRevision}" \
							-o -f "${CurrentInstallationCreationID}" ]; then
							MsgToPrint="FilesExist"
							VersionsMatch="false"
						fi;;
					VersionAlreadyInstalled)
						if [ -f "${CurrentInstallationInfo}" \
							-o -f "${CurrentInstallationManifest}" ]; then
							VersionsMatch="false"
						fi
						if [ -f "${CurrentInstallationRevision}" ]; then
							CurrentVersion=`grep 'FullVersionNumber:' \
								"${CurrentInstallationRevision}" | awk '{print $2}'`
						elif [ -f "${CurrentInstallationCreationID}" ]; then
								CurrentVersion=`grep 'FullVersionNumber:' \
									"${CurrentInstallationCreationID}" | awk '{print $2}'`
						fi
						if [ "${CurrentVersion}" != "${FullVersionNumber}" \
							-o "${InstallerType}" != "Math" ]; then
							VersionsMatch="false"
						else
							VersionsMatch="false"
						fi
						if [ "${VersionsMatch}" = "false" ]; then
							MsgToPrint="FilesExist"
						fi;;
					*)
						if [ -f "${CurrentInstallationRevision}" ]; then
							CurrentVersion=`grep 'FullVersionNumber:' \
							"${CurrentInstallationRevision}" | awk '{print $2}'`
						elif [ -f "${CurrentInstallationCreationID}" ]; then
							CurrentVersion=`grep 'FullVersionNumber:' \
							"${CurrentInstallationCreationID}" | awk '{print $2}'`
						elif [ -f "${CurrentInstallationInfo}" \
							-o -f "${CurrentInstallationManifest}" ]; then
							MsgToPrint="ThankYouForUpgrading"
							VersionsMatch="false"
						else
							if [ "${MsgToPrint}" = "None" -a \
								-z "`ls -a1 "${CurrentInstallationDir}" \
									| grep -v '^\.$' | grep -v '^\.\.$'`" ]; then
								MsgToPrint="None"
								VersionsMatch="false"
							else
								MsgToPrint="FilesExist"
								VersionsMatch="false"
							fi 
						fi
						if [ -f "${CurrentInstallationRevision}" \
							-o -f "${CurrentInstallationCreationID}" ]; then
							if [ "${CurrentVersion}" = "${FullVersionNumber}" \
								-a "${InstallerType}" = "Math" ]; then
								MsgToPrint="VersionAlreadyInstalled"
								VersionsMatch="true"
							else
								MsgToPrint="FilesExist"
								VersionsMatch="false"
							fi
						fi;;    
				esac
			fi # DirectoryOkay
		done # Dir

		if [ "${DirectoryOkay_}" = "true" \
			-a "${VarToSet}" = "TargetDirectory" ]; then

			if [ "${MsgToPrint}" != "None" ]; then

				PrintCopyText Text "${MsgToPrint}IntroductionText"

				if [ "${Automatic}" = "false" ]; then
					ans=""
					Overwriteans=""
				elif [ "${Overwriteans}" = "y" \
					-o "${Overwriteans}" = "Y" ]; then
					Overwriteans="y"
				elif [ "${Overwriteans}" = "n" \
					-o "${Overwriteans}" = "N" ]; then
					Overwriteans="n"
					for MadeDir in $MadeInstallDir; do
						rmdir "${Directory}/${MadeDir}"
					done
					MadeInstallDir=""
					PrintCopyText Error "OverwriteExitError"
					echo "${CopyText_}" 1>&2
					sigint="false"
					CleanUpOnDirtyExit_
				elif [ "${Overwriteans}" != "" ]; then
					for MadeDir in $MadeInstallDir; do
						rmdir "${Directory}/${MadeDir}"
					done
					MadeInstallDir=""
					PrintCopyText Error "BadOverwriteansError"
					echo "${CopyText_}" 1>&2
					sigint="false"
					CleanUpOnDirtyExit_
				fi

				while [ "${Overwriteans}" != "y" \
					-a "${Overwriteans}" != "n" ]; do

					if [ "${VersionsMatch}" = "true" ]; then
						PrintCopyText Prompt "OverwriteFilesPrompt" ""
					else
						PrintCopyText Prompt "OverwriteDirectoryPrompt" ""
					fi

					if [ "${Automatic}" = "false" ]; then
						read Overwriteans
					else
						Overwriteans=${Overwriteans:="y"}
						echo "${Overwriteans}"
					fi

					echo ""
					if [ "${Overwriteans}" = "n" \
						-o "${Overwriteans}" = "N" ]; then
						Overwriteans="n"
						DirectoryOkay_="false"
						for MadeDir in $MadeInstallDir; do
							rmdir "${Directory}/${MadeDir}"
						done
						MadeInstallDir=""
						if [ "${VersionsMatch}" = "true" ]; then
							userexit="true"
							sigint="false"
							CleanUpOnDirtyExit_
						fi
					elif [ "${Overwriteans}" = "y" \
						-o "${Overwriteans}" = "Y" ]; then
						Overwriteans="y"
					fi
				done
			fi # MsgToPrint
		fi # DirectoryOkay_
	else
		MakeDirectory_="true"
		Parent_="${Directory}"
		while [ "${ParentFound_}" != "true" ]; do
			NewDirectoryBase="${Parent_}"
			Parent_=`dirname "${Parent_}"`
			DirectoryParent="${Parent_}"
			if [ -d "${Parent_}" ]; then
				ParentFound_="true"
				touch "${Parent_}/thisisatest" > /dev/null 2>&1
				if [ "${?}" != "0" ]; then
					DirectoryOkay_="false"
					ans="y"
				else
					rm "${Parent_}/thisisatest"
					DirectoryOkay_="true"
				fi
			else
				ParentFound_="false"
			fi
			if [ "${DEBUG}" = "true" ]; then
				echo "<< \$Parent_ set to ${Parent_}. >>"
				echo "<< \$DirectoryOkay_ set to ${DirectoryOkay_}. >>"
			fi
		done
	fi # Directory

	if [ "${MakeDirectory_}" = "true" \
		-a "${Directory}" != "${DefaultDirectory}" \
		-a "${DirectoryOkay_}" = "true" ]; then

		if [ "${Automatic}" = "false" ]; then
			ans=""
			Overwriteans=""
		elif [ "${ans}" = "y" -o "${ans}" = "Y" ]; then
			ans="y"
		elif [ "${ans}" = "n" -o "${ans}" = "N" ]; then
			ans="n"
			PrintCopyText Error "ansExitError"
			echo "${CopyText_}" 1>&2
			sigint="false"
			CleanUpOnDirtyExit_
		elif [ "${ans}" != "" ]; then
			PrintCopyText Error "BadansError"
			echo "${CopyText_}" 1>&2
			sigint="false"
			CleanUpOnDirtyExit_
		fi
   
		while [ "${ans}" != "y" -a "${ans}" != "n" ]; do
      
			PrintCopyText Prompt "CreateDirectoryPrompt" ""

			if [ "${Automatic}" = "false" ]; then
				read ans
			else
				ans=${ans:="y"}
				echo "${ans}"
			fi
			echo ""

			if [ "${ans}" = "n" -o "${ans}" = "N" ]; then
				ans="n"
				DirectoryOkay_="null"
			elif [ "${ans}" = "y" -o "${ans}" = "Y" ]; then
				ans="y"
			fi
		done
	fi

	Defaultans=""
	Directory=""
	MsgToPrint=""

	if [ "${DEBUG}" = "true" ]; then
		echo "<< ### Exiting Function: CheckDirectory_() ### >>"
		echo "<< ### Exiting Function: CheckDirectory_() ### >>" 1>&2
	fi

}

# ----------------------------------------------------------------------------
# Function: CheckSpace_()

CheckSpace_() {
	if [ "${DEBUG}" = "true" ]; then
		echo "<< ### Function: CheckSpace_() ### >>"
		echo "<< ### Function: CheckSpace_() ### >>" 1>&2
	fi

	Directory="${1}"
	if [ "${DEBUG}" = "true" ]; then
		echo "<< Directory set to \"${Directory}\". >>"
	fi
	if [ -n "`echo \"${Directory}\" | egrep '^/'`" ]; then
		testdir="${Directory}"
	else
		testdir="`pwd`/${Directory}"
	fi

	while [ ! -d "${testdir}" ]; do
		testdir=`dirname "${testdir}"`
	done

	case "${DefaultSystemID}" in
		"AIX-Power64"|"HPUX-PA64"|IRIX-MIPS64)
			dfcommand="df -kP";;
		*)
		dfcommand="df -k";;
	esac

	dfresults=`${dfcommand} "${testdir}" | sed "1d" | tr '\n' ' ' | awk '{print $4}'`

	if [ "${DEBUG}" = "true" ]; then
		echo "<< dfresults set to ${dfresults} >>"
		echo "<< InstallSize set to ${InstallSize} >>"
	fi

	if [ -z "${dfresults}" ]; then
		echo "CRITICAL ERROR: dfresults not defined."
		echo "Critical Failure in CheckSpace_()" 1>&2
		sigint="false"
		CleanUpOnDirtyExit_
	fi

	if [ -z "${InstallSize}" ]; then
		echo "CRITICAL ERROR: InstallSize not defined."
		echo "Critical Failure in CheckSpace_()" 1>&2
		sigint="false"
		CleanUpOnDirtyExit_
	fi

	if [ ${dfresults} -ge ${InstallSize} ]; then
		SpaceToInstall=1
	fi

	if [ ${SpaceToInstall} -eq 0 -a "${Automatic}" = "true" ]; then
		PrintCopyText Error "NoSpaceAutomaticError"
		echo "${CopyText_}" 1>&2
		sigint="false"
		CleanUpOnDirtyExit_
	fi

	# Clean up
	dfcommand=""
	dfresults=""
	testdir=""
   
	if [ "${DEBUG}" = "true" ]; then
		echo "<< ### Exiting Function: CheckSpace_() ### >>"
		echo "<< ### Exiting Function: CheckSpace_() ### >>" 1>&2
	fi

}

# ----------------------------------------------------------------------------
# Function: CopyManPages()

CopyManPages() {
   if [ "${DEBUG}" = "true" ]; then
      echo "<< ### Function: CopyManPages() ### >>"
      echo "<< ### Function: CopyManPages() ### >>" 1>&2
   fi

   # Possible man page directories. 
   DefaultManPageDir="/usr/man/man1"
   LinuxManPageDir="/usr/share/man/man1"
   SGIManPageDir="/usr/share/catman/u_man/cat1"
   LocalManPageDir="/usr/local/man/man1"

   for Dir in $InstallDir; do    
     if [ "${Dir}" = "NoInstallDirSpecified" ]; then
         ManSrcDir="${TargetDirectory}/SystemFiles/SystemDocumentation/Unix/"
      else
         ManSrcDir="${TargetDirectory}/${Dir}/SystemFiles/SystemDocumentation/Unix/"
      fi
      if [ -d "${ManSrcDir}" ]; then
         ManPages=`ls -1 "${ManSrcDir}"`
      fi
      if [ -n "${AllManPages}" ]; then
         AllManPages="${AllManPages} ${ManPages}"
      else
         AllManPages="${ManPages}"
      fi

      if [ -n "${ManPages}" -a -z "${ManPageDirectory}" ]; then
         if [ ! -w "${DefaultManPageDir}" ]; then
            if [ ! -w "${LinuxManPageDir}" ]; then
               if [ ! -w "${SGIManPageDir}" ]; then
                  if [ ! -w "${LocalManPageDir}" ]; then
                     ManPageDirectory=""
                  else
                     ManPageDirectory="${LocalManPageDir}"
                  fi
               else
                  ManPageDirectory="${SGIManPageDir}"
               fi
            else
               ManPageDirectory="${LinuxManPageDir}"
            fi
         else
            ManPageDirectory="${DefaultManPageDir}"
         fi
      fi

      if [ -n "${ManPageDirectory}" ]; then
         for ManPage in $ManPages; do
            if [ -f "${ManPageDirectory}/${ManPage}" ]; then
               if [ -n "${ExistingManPages}" ]; then
                  ExistingManPages="${ExistingManPages} ${ManPage}"
               else
                  ExistingManPages="${ManPage}"
               fi
               mv -f "${ManPageDirectory}/${ManPage}" "${ManPageDirectory}/${ManPage}.old"
            fi
            cp -f "${ManSrcDir}/${ManPage}" "${ManPageDirectory}/${ManPage}"
         done
      fi
   done

   if [ "${DEBUG}" = "true" ]; then
      echo "<< ### Exiting Function: CopyManPages() ### >>"
      echo "<< ### Exiting Function: CopyManPages() ### >>" 1>&2
   fi

}


# ---------------------------------------------------------------------------
# Function: FindSoundDrivers_()

FindSoundDrivers_() {
	if [ "${DEBUG}" = "true" ]; then
		echo "<< ### Function: FindSoundDrivers_() ### >>"
		echo "<< ### Function: FindSoundDrivers_() ### >>" 1>&2
	fi

	if [ "${DEBUG}" = "true" ]; then
		echo "<< ### Exiting Function: FindSoundDrivers_() ### >>"
	 	echo "<< ### Exiting Function: FindSoundDrivers_() ### >>" 1>&2
	fi

}	


# ----------------------------------------------------------------------------
# Function: GetDefaultSystemID_()

GetDefaultSystemID_() {
   if [ "${DEBUG}" = "true" ]; then
      echo "<< ### Function: GetDefaultSystemID_() ### >>"
      echo "<< ### Function: GetDefaultSystemID_() ### >>" 1>&2
   fi

   Default64SystemID=""
   case `uname -s` in
      Linux)
         case `uname -m` in
            ia64)
               DefaultSystemID="Linux-IA64";;
            i?86)
               DefaultSystemID="Linux";;
            x86_64)
               DefaultSystemID="Linux";;
            *)
               DefaultSystemID="Unknown";;
         esac;;
      *)
         DefaultSystemID="Unknown";;
   esac

   if [ "${DEBUG}" = "true" ]; then
      echo "<< ### Exiting Function: GetDefaultSystemID_() ### >>"
      echo "<< ### Exiting Function: GetDefaultSystemID_() ### >>" 1>&2
   fi

}

# ----------------------------------------------------------------------------
# Function: GetDirectory()

GetDirectory() {
   if [ "${DEBUG}" = "true" ]; then
      echo "<< ### Function: GetDirectory() ### >>"
      echo "<< ### Function: GetDirectory() ### >>" 1>&2
   fi

   VarToSet="${1}"

   DirectoryOkay_="null"

   if [ "${Automatic}" = "true" ]; then
      DirSetTo=`eval echo '${'${VarToSet}'}'`
   else
      DirSetTo=""
   fi

   DefaultDirectory=`eval echo '${Default'${VarToSet}'}'`
   DirectoryBase="${DirSetTo}"

   if [ -z "${DefaultDirectory}" ]; then
      echo "CRITICAL FAILURE: GetDirectory() Error"
      echo "  \$Default${VarToSet} not defined."
      echo "Critical Failure in GetDirectory." 1>&2
      sigint="false"
      CleanUpOnDirtyExit_
   fi

   while [ "${DirectoryOkay_}" != "true" ]; do
      PrintCopyText Prompt "${VarToSet}Prompt" "${DefaultDirectory}"

      if [ "${Automatic}" = "false" ]; then
         read DirectoryBase
      else
         echo "${DirectoryBase}"
      fi

      echo ""
      DirectoryBase=${DirectoryBase:="$DefaultDirectory"}
      eval "${VarToSet}Base=\"${DirectoryBase}\""

      if [ "${DirectoryBase}" != "/" ]; then
         DirectoryBase=`echo "${DirectoryBase}" | \
            sed -e 's/\/$//'`
      fi

      CheckDirectory_ "${DirectoryBase}"

      if [ "${ans}" = "y" -o "${Overwriteans}" = "y" ]; then
         if [ "${DirectoryOkay_}" = "false" ]; then
            if [ "${MakeDirectory_}" = "true" ]; then
               PrintCopyText Error "CreateDirectoryError"
            else
               PrintCopyText Error "WriteToDirectoryError"
            fi
            PrintCopyText Error "MayNeedRootError"
         fi
      fi

      if [ "${DirectoryOkay_}" != "true" \
         -a "${Automatic}" = "true" ]; then
         echo "${CopyText_}" 1>&2
         sigint="false"
         CleanUpOnDirtyExit_
      fi
   done

   # Set variables for the directory, the directory's pre-existing
   # parent directory, and the lowest created directory.
   eval "${VarToSet}=\"${DirectoryBase}\""
   eval "${VarToSet}Parent=\"${DirectoryParent}\""
   eval "New${VarToSet}Base=\"${NewDirectoryBase}\""

   if [ "${DEBUG}" = "true" ]; then
      echo "<< ${VarToSet} set to \"${DirectoryBase}\". >>"
      echo "<< ${VarToSet}Parent set to \"${DirectoryParent}\". >>"
      echo "<< New${VarToSet}Base set to \"${NewDirectoryBase}\". >>"
   fi

   if [ "${MakeDirectory_}" = "true" ]; then
      eval "Make${VarToSet}=\"true\""
   fi

   DefaultDirectory=""
   DirectoryBase=""
   DirectoryParent=""
   DirSetTo=""
   NewDirectoryBase=""
   VarToSet=""

   if [ "${DEBUG}" = "true" ]; then
      echo "<< ### Exiting Function: GetDirectory() ### >>"
      echo "<< ### Exiting Function: GetDirectory() ### >>" 1>&2
   fi

}

# ----------------------------------------------------------------------------
# Function: InfoInitialize()

InfoInitialize() {
   if [ "${DEBUG}" = "true" ]; then
      echo "<< ### Function: InfoInitialize() ### >>"
      echo "<< ### Function: InfoInitialize() ### >>" 1>&2
   fi

   # Need hostname for gridMath url
   HOST=`hostname`

   # Get all installation options and information from the info files.
   ProductName=`grep '^ProductName' ${ProductInfoFileList} | \
      awk '{print $3}' | sort | uniq`

   OrderList ProductName "Mathematica"

   ProductTitle=`grep '^ProductTitle' ${ProductInfoFileList} | \
      tr -s ' ' | sed -e 's/^.*ProductTitle //g' | \
      sort | uniq | tr '\n' ' '`
   ProductTitle=`echo "${ProductTitle}" | sed -e 's/ $//g'`
   
   FullProductName=`grep '^FullProductName' ${ProductInfoFileList} | \
      tr -s ' ' | sed -e 's/^.*FullProductName //g' | \
      sort | uniq | tr '\n' ' '`
   FullProductName=`echo "${FullProductName}" | sed -e 's/ $//g'`
   
   VersionNumber=`grep '^VersionNumber' ${ProductInfoFileList} | \
      awk '{print $2}' | sort | uniq | tr '\n' ' ' | \
      tr -s ' '`
   VersionNumber=`echo "${VersionNumber}" | sed -e 's/^ //g' | \
      sed -e 's/ $//g'`

   ReleaseNumber=`grep '^ReleaseNumber' ${ProductInfoFileList} | \
      awk '{print $2}' | sort | uniq | tr '\n' ' ' | \
      tr -s ' '`
   ReleaseNumber=`echo "${ReleaseNumber}" | sed -e 's/^ //g' | \
      sed -e 's/ $//g'`

   MinorReleaseNumber=`grep '^MinorReleaseNumber' ${ProductInfoFileList} \
      | awk '{print $2}' | sort | uniq | tr '\n' ' ' | \
      tr -s ' '`
   MinorReleaseNumber=`echo "${MinorReleaseNumber}" | sed -e 's/^ //g' | \
      sed -e 's/ $//g'`

   CopyrightYearList=`grep '^CopyrightYear' ${ProductInfoFileList} | \
      awk '{print $2}' | sort | uniq | tr '\n' ' ' | tr -s ' '`
   CopyrightYearList=`echo "${CopyrightYearList}" | sed -e 's/ $//g'`
   CopyrightYear=`echo "${CopyrightYear}" | sed -e 's/^ //g' | \
      sed -e 's/ $//g' | sed -e 's/ /, /g'`

   CreationID=`grep '^CreationID' ${ProductInfoFileList} | \
      awk '{print $2}' | sort | uniq | tr '\n' ' ' | \
      tr -s ' '`
   CreationID=`echo "${CreationID}" | sed -e 's/^ //g' | sed -e 's/ $//g'`

   SystemIDList=`grep '^SystemID' ${ProductInfoFileList} | \
      awk '{print $2}' | sed -e 's/^None//g' | sort | \
      uniq | tr '\n' ' '`
   SystemIDList=`echo "${SystemIDList}" | sed -e 's/^ //g' | \
      sed -e 's/ $//g'`

   OrderList SystemIDList "${DefaultSystemID}"

   IDList=`grep '^InstallID' ${ProductInfoFileList} | \
      awk '{print $2}' | sed -e 's/^None//g' | sort | \
      uniq | tr '\n' ' '`

   if [ "${DefaultSystemID}" = "Linux-x86-64" ]; then
	OrderList IDList "Linux"
   else
	OrderList IDList "${DefaultSystemID}"
   fi 

   LanguageList=`grep '^Language' ${ProductInfoFileList} | \
      awk '{print $2}' | sort | uniq | tr '\n' ' '`
   LanguageList=`echo "${LanguageList}" | sed -e 's/^ //g' | \
      sed -e 's/ $//g'`

   OrderList LanguageList "${DefaultLanguage}"

   FeatureList=`grep '^Feature' ${ProductInfoFileList} | \
      awk '{print $2}' | tr ',' ' ' | tr ' ' '\n' | \
      sort | uniq | tr '\n' ' '`

   OrderList FeatureList "Full"

   ExecScriptsList=`grep '^ExecScripts' ${ProductInfoFileList} | \
      tr -s ' ' | sed -e 's/^.*ExecScripts //g' | \
      sort | uniq | tr '\n' ' '`
   ExecScriptsList=`echo "${ExecScriptsList}" | sed -e 's/ $//g'`

   InstallBase=`grep '^InstallBase' ${ProductInfoFileList} | \
      awk '{print $2}' | sort | uniq | \
      sed -e 's/~/\$\{HOME\}/g' | sed '1p;d'`
   
   InstallBase=`eval echo "${InstallBase}"`

   if [ "${DefaultTargetDirectory}" = "" ]; then
      DefaultTargetDirectory="${InstallBase}"
   fi

   InstallDir=`grep '^InstallDir' ${ProductInfoFileList} | \
      awk '{print $2}' | grep -v '^$' | sort | uniq | tr '\n' ' '`
   InstallDir=`echo "${InstallDir}" | tr -s ' ' | sed -e 's/^ //g' |
      sed -e 's/ $//g'`
      
   InstallerType=`grep '^InstallerType' ${ProductInfoFileList} | \
      awk '{print $2}' | grep -v '^$' | sort | uniq | tr '\n' ' '`
   InstallerType=`echo "${InstallerType}" | tr -s ' ' | sed -e 's/^ //g' |
      sed -e 's/ $//g'`

   if [ -z "${InstallDir}" ]; then
      InstallDir="NoInstallDirSpecified"
   fi
   
   DefaultExecDirectory=`grep '^DefaultExecDirectory' ${ProductInfoFileList} | \
      awk '{print $2}' | grep -v '^$' | sort | uniq | tr '\n' ' '`
   DefaultExecDirectory=`echo "${DefaultExecDirectory}" | tr -s ' ' | sed -e 's/^ //g' |
      sed -e 's/ $//g'`
      
   if [ -z "${DefaultExecDirectory}" ]; then
      DefaultExecDirectory="/usr/local/bin"
   fi
      
   if [ "${DEBUG}" = "true" ]; then
      echo "<< ProductName set to \"${ProductName}\". >>"
      echo "<< ProductTitle set to \"${ProductTitle}\". >>"
      echo "<< FullProductName set to \"${FullProductName}\". >>"
      echo "<< VersionNumber set to \"${VersionNumber}\". >>"
      echo "<< ReleaseNumber set to \"${ReleaseNumber}\". >>"
      echo "<< MinorReleaseNumber set to \"${MinorReleaseNumber}\". >>"
      echo "<< CopyrightYearList set to \"${CopyrightYearList}\". >>"
      echo "<< CreationID set to \"${CreationID}\". >>"
      echo "<< SystemIDList set to \"${SystemIDList}\". >>"
      echo "<< IDList set to \"${IDList}\". >>"
      echo "<< LanguageList set to \"${LanguageList}\". >>"
      echo "<< FeatureList set to \"${FeatureList}\". >>"
      echo "<< ExecScriptsList set to \"${ExecScriptsList}\". >>"
      echo "<< InstallBase set to \"${InstallBase}\". >>"
      echo "<< InstallDir set to \"${InstallDir}\". >>"
      echo "<< InstallerType set to \"${InstallerType}\". >>"
   fi

   if [ -n "`echo ${VersionNumber} | awk '{print $2}'`" \
      -o -n "`echo ${ReleaseNumber} | awk '{print $2}'`" \
      -o -n "`echo ${MinorReleaseNumber} | awk '{print $2}'`" \
      ]; then
      echo "CRITICAL FAILURE: InfoInitialize() Error"
      echo "  Version number mismatch."
      echo "Critical Failure in InfoInitialize. Version number mismatch." 1>&2 
      sigint="false"
      CleanUpOnDirtyExit_
   fi

   FullVersionNumber="${VersionNumber}.${ReleaseNumber}.${MinorReleaseNumber}"

   if [ -n "`echo ${CreationID} | awk '{print $2}'`" ]; then
      echo "CRITICAL FAILURE: InfoInitialize() Error"
      echo "  CreationID mismatch."
      echo "Critical Failure in InfoInitialize. Creation ID mismatch." 1>&2
      sigint="false"
      CleanUpOnDirtyExit_
   fi

   # clean up
   Feature=""
   InfoFindPath_=""
   InfoFile_=""
   InfoFileList_=""
   Language=""
   ProductNameMatch_=""
   SystemID=""
   InstallID=""

   if [ "${DEBUG}" = "true" ]; then
      echo "<< ### Exiting Function: InfoInitialize() ### >>"
      echo "<< ### Exiting Function: InfoInitialize() ### >>" 1>&2
   fi

}

# ----------------------------------------------------------------------------
# Function: Initialize()

Initialize() {
   umask 022

   # Set Flags to initial values
   Help="false"
   sigint="true"
   userexit="false"

   if [ -z "${InstallerPath}" ]; then
      echo "CRITICAL FAILURE: Fundamental Error"
      echo "  \$InstallerPath not defined."
      echo "Critical Failure in Initialize." 1>&2 
      sigint="false"
      CleanUpOnDirtyExit_
   fi

   # Make sure a TERM is defined.
   if [ "${TERM}" = "unknown" -o "${TERM}" = "dumb" -o -z "${TERM}" ]; then
      TERM="vt100"
      export TERM
   fi

   # Default term width (for early error messages).
   TermWidth=80
   TWmin=75

   # Create the ErrorFile. It will be removed by CleanUp_() if it
   # is empty when the install finishes.
   ErrorFile="/tmp/InstallErrors-$$"
   touch "${ErrorFile}"
   exec 2>"${ErrorFile}"

   GetDefaultSystemID_

   # Get text from the greeting file until the installer language selection

   GreetingFile=`ls -1 "${InstallerPath}/TextResources" | grep "Greeting"`

   InstallerTitle="${InstallerPath}/TextResources/${GreetingFile}"
   InstallerText="${InstallerPath}/TextResources/${GreetingFile}"
   InstallerError="${InstallerPath}/TextResources/${GreetingFile}"
   InstallerPrompt="${InstallerPath}/TextResources/${GreetingFile}"
   InstallerVerbose="${InstallerPath}/TextResources/${GreetingFile}"

   if [ ! -f "${InstallerTitle}" ]; then
      echo "CRITICAL FAILURE: Fundamental Error"
      echo " Installer text not found."
      echo "Critical Failure in Initialize." 1>&2
      sigint="false"
      CleanUpOnDirtyExit_
   fi

   # Check for gunzip
   gunzip --version > /dev/null 2>&1
   if [ "${?}" != "0" ]; then
      PrintCopyText Text "GunzipError"
      echo "${CopyText_}" 1>&2
      sigint="false"
      CleanUpOnDirtyExit_
   fi

   # The user and group id are used later to fix ownership
   # permissions on the installed files.
   InstallUser=`id -u`
   InstallGroup=`id -g`

   # see what echo does and set ${n} and ${c} accordingly
   echo "test\c" | grep -s c > /dev/null 2>&1
   if [ "${?}" != "0" ]; then
      n=""
      c="\c"
   else
      n="-n"
      c=""
   fi

   # Find the info files.
   InfoFindPath_=`dirname "${InstallerPath}"`
   InfoFileList_=`find "${InfoFindPath_}" -name "info" -print`
   ProductInfoFileList=`echo "${InfoFileList_}" | sed -e 's/^ //g'` 

   if [ -z "${ProductInfoFileList}" ]; then
      echo "CRITICAL FAILURE: Initialize() Error"
      echo "  No info files found."
      echo "Critical Failure in Initialize." 1>&2 
      sigint="false"
      CleanUpOnDirtyExit_
   fi

   # Set the file name of the install archives.
   ArchiveFileName="contents.tar.gz"

   # Initialize space test.
   SpaceToInstall=0

   # Clear all install variables.
   isRoot=""
   AllManPages=""
   ans=""
   ExecDirectory=""
   ExistingManPages=""
   InstallerLanguage=""
   InstallFeature=""
   InstallLanguage=""
   InstallIDList=""
   InstallSystemIDList=""
   ManPageDirectory=""
   TargetDirectory=""
   
}


# ----------------------------------------------------------------------------
# Function: InstallAsRoot()

InstallAsRoot() {
   if [ "${DEBUG}" = "true" ]; then
       echo "<< ### Function: InstallAsRoot() ### >>"
       echo "<< ### Function: InstallAsRoot() ### >>" 1>&2
   fi

   isRoot="true"

   if [ "${InstallUser}" -ne 0 ]; then
       isRoot="false"

       if [ "${InstallerType}" = "gridMath" ]; then
           PrintCopyText Text "NonRootUserWrs"
    
           ans=""
           while [ "${ans}" != "y" -a "${ans}" != "n" ]; do
                  PrintCopyText Prompt "InstallAsRootPrompt" ""
	
                  if [ "${Automatic}" = "false" ]; then
                      read ans
                  else
                      ans=${ans:="y"}
                      echo "${ans}"
                  fi
                  echo ""
                  if [ "${ans}" = "n" -o "${ans}" = "N" ]; then
                      exit 0
                  elif [ "${ans}" = "y" -o "${ans}" = "Y" ]; then
                        return 0
                  fi  
           done
       fi
   else
       return 0
   fi

   if [ "${DEBUG}" = "true" ]; then
       echo "<< ### Exiting Function: InstallAsRoot() ### >>"
       echo "<< ### Exiting Function: InstallAsRoot() ### >>" 1>&2
   fi

}


# ----------------------------------------------------------------------------
# Function: InstallBeagleSearch()

InstallBeagleSearch() {
   if [ "${DEBUG}" = "true" ]; then
       echo "<< ### Function: InstallBeagleSearch() ### >>"
       echo "<< ### Function: InstallBeagleSerach() ### >>" 1>&2
   fi
   	
   ans=""	
   while [ "${ans}" != "y" -a "${ans}" != "n" ]; do	  
          PrintCopyText Prompt "InstallBeagleSearchPrompt"
	
          if [ "${Automatic}" = "false" ]; then
              read ans
          else
              ans=${ans:="n"}
              echo "${ans}"
          fi	
          
          echo ""
          if [ "${ans}" = "n" -o "${ans}" = "N" ]; then
              continue

          elif [ "${ans}" = "y" -o "${ans}" = "Y" ]; then

                if [ `uname -m` = 'x86_64' ]; then
                   _origSystemID="${DefaultSystemID}"
                   DefaultSystemID="Linux-x86-64"
                fi

                beagleDirs="/etc/beagle /usr/etc/beagle /usr/local/etc/beagle"
                for dir in ${beagleDirs}; do

                   if [ -d "${dir}" ]; then

                       filtersFile="${s}/external-filters.xml"

                       if [ -f "${filtersFile}" ]; then
                           if [ ! -f "${filtersFile}.wolfram.bak" ]; then
                               cp "${filtersFile}" "${filtersFile}.wolfram.bak"
                           fi

                           awk '/<!-- Mathematica Notebook filter -->/{c=6}!(c&&c--)' "${filtersFile}" > "${filtersFile}.tmp"
                           sed 's|^</external-filters>||' "${filtersFile}.tmp" > "${filtersFile}" ; rm "${filtersFile}.tmp"

                       else
                           cat > "${filtersFile}" << EOF
												   
                           <?xml version=\"1.0\" encoding=\"utf-8\"?>
												  
                           <external-filters>
												   
EOF
                       fi

                           cat >> "${filtersFile}" << EOF

                           <!-- Mathematica Notebook filter -->
                           <filter>
                             <extension>.nb</extension>
                             <command>${FullTargetDirectory}/SystemFiles/FrontEnd/Binaries/${DefaultSystemID}/nbcat</command>
                             <arguments>%s</arguments>
                           </filter>
      
                           </external-filters>
EOF

                       break

                   else
                         continue
                   fi

                done

		# Clean up
    	        DefaultSystemID="${_origSystemID}"
          fi
   done

   if [ "${DEBUG}" = "true" ]; then
       echo "<< ### Exiting Function: InstallBeagleSearch() ### >>"
       echo "<< ### Exiting Function: InstallBeagleSearch() ### >>" 1>&2
   fi

}

       
# ----------------------------------------------------------------------------
# Function: InstallProduct()

InstallProduct() {
	if [ "${DEBUG}" = "true" ]; then
		echo "<< ### Function: InstallProduct() ### >>"
		echo "<< ### Function: InstallProduct() ### >>" 1>&2
	fi

	# Just to let people know we're doing something...
	PrintCopyText Text "NowInstallingText"

	DotTextWidth_=0
	TotalDots_=0
	# Print the open and close [] for the dots to go between
	if [ "${Silent}" != "true" ]; then
		if [ "${Verbose}" != "true" \
			-o "${DefaultSystemID}" = "DEC-AXP" \
			-o "${DefaultSystemID}" = "HPUX-PA64" \
			-o "${DefaultSystemID}" = "IRIX-MIPS64" \
			-o "${DefaultSystemID}" = "MacOSX" ]; then
			Spacing_=`expr ${TermWidth} - 3`
			WhiteSpace_=`printf "%-${Spacing_}s"`
			DotText_="[${WhiteSpace_}]"
			DotTextWidth_=`echo "${DotText_}" | wc -c`
			ExtraTextSpace=`expr ${TermWidth} - ${DotTextWidth_}`
			Spacing_=`expr ${ExtraTextSpace} / 2`
			WhiteSpace_=`printf "%-${Spacing_}s"`

			echo $n "${WhiteSpace_}${DotText_}$c"

			DotTextWidth_=`expr ${DotTextWidth_} - 2`
			BackupSpace_=`printf "%-${DotTextWidth_}s" | tr ' ' '\b'`
			echo $n "${BackupSpace_}$c"
			DotTextWidth_=`expr ${DotTextWidth_} - 1`
			TotalDots_=${DotTextWidth_}
		fi
	fi
    
	InstallSize=0
	InstallInfoFileList=""

	# From $ProductInfoFileList, we need to extract only the info files
	# that contain the InstallIDs from $InstallIDList, the Language
	# from $InstallLanguage, and the Feature from $InstallFeature.
	# We will call this new info file list $InstallInfoFileList.
	for InfoFile_ in ${ProductInfoFileList}; do

		TestLanguage_=`grep '^Language ' "${InfoFile_}" | awk '{print $2}'`
		if [ "${InstallLanguage}" != "${TestLanguage_}" ]; then
			continue
		fi

		TestInstallID_=`grep '^InstallID ' "${InfoFile_}" | awk '{print $2}'`

		TestInstallIDList_=`echo "${InstallIDList}" | sed -e 's/ /::/g'`
		TestInstallIDList_=":${TestInstallIDList_}:"
		InstallIDCheck_=`echo "${TestInstallIDList_}" | \
			sed -e 's/:'"${TestInstallID_}"'://g'`
		if [ "${InstallIDCheck_}" = "${TestInstallIDList_}" ]; then
			continue
		fi
		TestFeatureList_=`grep "Feature " "${InfoFile_}" | \
			awk '{print $2}' | tr ',' ' '`
		TestFeatureList_=" ${TestFeatureList_} "

		FeatureCheck_="${InstallFeature}"
		for TestFeature_ in $TestFeatureList_; do
			FeatureCheck_=`echo "${FeatureCheck_}" | \
				sed -e 's/'"${TestFeature_}"'//g'`
		done
		if [ "${FeatureCheck_}" = "${InstallFeature}" ]; then
			continue
		fi

		InfoDir_=`dirname "${InfoFile_}"`
		InstallSizeTemp_=`gunzip -l "${InfoDir_}"/*.gz | sed "2p;d" | awk '{ print $2 }'`
		InstallSize=`expr ${InstallSizeTemp_} / 1024 + ${InstallSize} + 1`
		InfoFile_=`echo "${InfoFile_}" | tr ' ' ':'`
		InstallInfoFileList="${InstallInfoFileList} ${InfoFile_}"
	done

	CheckSpace_ "${TargetDirectory}"

	if [ ${SpaceToInstall} -eq 1 ]; then

		InstallInfoFileList=`echo "${InstallInfoFileList}" | sed -e 's/^ //g'`

		# Create $TargetDirectory if necessary.
		if [ "${MakeTargetDirectory}" = "true" ]; then
			if [ ! -d "${TargetDirectory}" ]; then
				mkdir -p "${TargetDirectory}"
			fi
		fi
      
		TargetDirectory=`cd "${TargetDirectory}"; pwd`

		# Make the InstallDirs if necessary.
		for Dir in $InstallDir; do
			if [ ! -d "${TargetDirectory}/${Dir}" \
				-a "${Dir}" != "NoInstallDirSpecified" ]; then
				mkdir -p "${TargetDirectory}/${Dir}"
			fi
		done

		# Backup files in the TargetDirector(y/ies).
		BackupComplete="null"
		if [ "${Overwriteans}" = "y" -a "${VersionsMatch}" != "true" ]; then
			BackupDirBase="BackupDir-$$"
			for Dir in $InstallDir; do
				if [ "${Dir}" = "NoInstallDirSpecified" ]; then
					BackupDir="${TargetDirectory}/${BackupDirBase}"
				else
					BackupDir="${TargetDirectory}/${Dir}/${BackupDirBase}"
				fi
				FullTargetDirectory=`dirname "${BackupDir}"`
				FileName=`ls -a1 "${FullTargetDirectory}" | grep -v '^\.$' | \
					grep -v '^\.\.$' | sort | sed '1p;d'`
				if [ -n "${FileName}" ]; then
					mkdir "${BackupDir}"

					if [ "${Verbose}" = "true" ]; then
						PrintCopyText Verbose "MovingFilesToBackupVerbose"
					fi

					#CurrentDir=`pwd`
					#cd "${FullTargetDirectory}"
					#mv ${FileName} ${BackupDirBase}/.
					#cd "${CurrentDir}"

					FileName=`ls -a1 "${FullTargetDirectory}" | \
						grep -v '^\.$' | grep -v '^\.\.$' | \
						grep -v "^${BackupDirBase}$" | sort | \
						sed '1p;d'`
					while [ -n "${FileName}" ]; do
						if [ "${Verbose}" = "true" ]; then
							PrintCopyText Verbose "MovingFileVerbose"
						fi

						mv "${FullTargetDirectory}/${FileName}" "${BackupDir}/."
						FileName=`ls -a1 "${FullTargetDirectory}" | \
							grep -v '^\.$' | grep -v '^\.\.$' | \
							grep -v "^${BackupDirBase}$" | sort | \
							sed '1p;d'`
               		done
            	fi
         	done
         	BackupComplete="true"
		else
         	BackupDirBase=""
		fi

		# Make the temporary installation director(y/ies).
		InstallTempDirBase=".InstallTemp-$$"
		for Dir in $InstallDir; do
			if [ "${Dir}" = "NoInstallDirSpecified" ]; then
				FullInstallTempDir="${TargetDirectory}/${InstallTempDirBase}"
			else
				FullInstallTempDir="${TargetDirectory}/${Dir}/${InstallTempDirBase}"
			fi

			if [ ! -d "${FullInstallTempDir}" ]; then
				mkdir "${FullInstallTempDir}"
			fi
		done

		ComponentTargetList_=""
		LastInfoFile_=`echo "${InstallInfoFileList}" | tr ' ' '\n' | \
			tail -n 1 | tr ':' ' '`

		# Extract the files from the product archives.
		for InfoFile_ in $InstallInfoFileList; do

			InfoFile_=`echo "${InfoFile_}" | tr ':' ' '`
			SourceDirectory_=`dirname "${InfoFile_}"`

			# If we are using multiple installation directories, we need
			# to determine which temporary directory to put files in.
			if [ "${InstallDir}" != "NoInstallDirSpecified" ]; then
				InstallTempDir=`grep "^InstallDir" "${InfoFile_}" | \
					awk '{print $2}' | tr -s ' ' | sed -e 's/^ //g' | \
					sed -e 's/ $//g'`
            	FullInstallTempDir="${TargetDirectory}/${InstallTempDir}/${InstallTempDirBase}"
         	fi

			cd "${FullInstallTempDir}"

			FullTargetDirectory=`dirname "${FullInstallTempDir}"`

			InstallSizeTemp_=`gunzip -l "${SourceDirectory_}/${ArchiveFileName}" \
				| sed "2p;d" | awk '{ print $2 }'`
			InstallSizeTemp_=`expr ${InstallSizeTemp_} / 1024`

			ComponentTarget=`gunzip -c "${SourceDirectory_}/${ArchiveFileName}" | \
				tar -tf - | grep '^[A-Za-z0-9]' | tr '/' ' ' | \
				awk '{print $1}' | sort | uniq`

			ComponentNameList=""

			# This will eventually be used for better clean up on exit...
			if [ "${InstallDir}" = "NoInstallDirSpecified" ]; then
				ComponentTargetList_="${ComponentTargetList_} ${ComponentTarget}"
				export ComponentTargetList_
				export ComponentNameList
			else
				ComponentName=`echo "${InstallTempDir}" | sed -e 's/\///g' | \
					sed -e 's/ //g'`
				eval "${ComponentName}ComponentTargetList_=\"`echo '${'${ComponentName}'ComponentTargetList_}'` ${ComponentTarget}\""
				export `echo "${ComponentName}ComponentTargetList_"`
				ComponentNameList="${ComponentNameList} ${ComponentName}"
				export ComponentNameList
			fi

			for Target in $ComponentTarget; do
				if [ -d "${FullTargetDirectory}/${Target}" \
					-a "${Overwriteans}" != "y" ]; then
					ComponentTargetExists="true"
					echo ""
					echo ""
					PrintCopyText Error "ComponentTargetError"
					echo "${CopyText_}" 1>&2
					sigint="false"
					CleanUpOnDirtyExit_
				elif [ -d "${FullTargetDirectory}/${Target}" \
					-a "${VersionsMatch}" != "true" ]; then
					rm -rf "${FullTargetDirectory}/${Target}"
				fi
			done

			if [ "${Verbose}" = "true" \
				-a "${DefaultSystemID}" != "MacOSX" ]; then
				gunzip -c "${SourceDirectory_}/${ArchiveFileName}" | tar -xvmf -
			else
				gunzip -c "${SourceDirectory_}/${ArchiveFileName}" | tar -xmf -

				if [ "${Silent}" != "true" ]; then
					if [ "${InfoFile_}" = "${LastInfoFile_}" ]; then
						Dots_=`printf "%-${DotTextWidth_}s" | tr ' ' '*'`
						DotTextWidth_=0
					else
						Dots_=`expr ${InstallSize} / ${TotalDots_}`
						Dots_=`expr ${InstallSizeTemp_} / ${Dots_}`
						DotTextWidth_=`expr ${DotTextWidth_} - ${Dots_}`
						Dots_=`printf "%-${Dots_}s" | tr ' ' '*'`
					fi

					if [ ${DotTextWidth_} -eq 0 ]; then
						echo "${Dots_}"
						echo ""
					else
						echo ${n} "${Dots_}${c}"
					fi
				fi
			fi

			# This should never happen, but just to be sure...
			if [ -f "${ArchiveFileName}" ]; then
				if [ "${DEBUG}" = "true" ]; then
					echo "<< Removing \"${ArchiveFileName}\". >>"
				fi
				rm -f "${ArchiveFileName}"
			fi
		done # InfoFile_

		for Dir in $InstallDir; do
			if [ "${InstallDir}" = "NoInstallDirSpecified" ]; then
				FullInstallTempDir="${TargetDirectory}/${InstallTempDirBase}"
			else
				FullInstallTempDir="${TargetDirectory}/${Dir}/${InstallTempDirBase}"
			fi

			FullTargetDirectory=`dirname "${FullInstallTempDir}"`

			if [ "${DEBUG}" = "true" ]; then
				echo "<< Changing file owner to \"${InstallUser}\" and group to \"${InstallGroup}\". >>"
			fi
         
			chgrp -fhR "${InstallGroup}" "${FullInstallTempDir}"
			chown -fhR "${InstallUser}" "${FullInstallTempDir}"

			if [ "${InstallDir}" = "NoInstallDirSpecified" ]; then
				ComponentTargetList="${ComponentTargetList_}"
			else
				ComponentName=`echo "${Dir}" | sed -e 's/\///g' | sed -e 's/ //g'`
				ComponentTargetList=`eval echo '${'${ComponentName}'ComponentTargetList_}'`
			fi

			ComponentTargetList=`echo "${ComponentTargetList}" | tr ' ' '\n' |  \
				sort | uniq | tr '\n' ' '`
			ComponentTargetList=`echo "${ComponentTargetList}" | \
				sed -e 's/^ //g' | sed -e 's/ $//g'`

			for ComponentTarget_ in ${ComponentTargetList}; do
				if [ "${Verbose}" = "true" ]; then
					PrintCopyText Verbose "MoveComponentDirVerbose"
				fi
				if [ "${VersionsMatch}" = "true" ]; then
					cp -pfR "${FullInstallTempDir}/${ComponentTarget_}" "${FullTargetDirectory}" 1>&2
				else
					mv -f "${FullInstallTempDir}/${ComponentTarget_}" "${FullTargetDirectory}" 1>&2
				fi
			done
      
			echo "FullVersionNumber: ${FullVersionNumber}" > "${FullTargetDirectory}/.Revision"
			echo "CreationID: ${CreationID}" >> "${FullTargetDirectory}/.Revision"

			echo "${CreationID}" > "${FullTargetDirectory}/.CreationID"
			echo "${FullVersionNumber}" > "${FullTargetDirectory}/.VersionID"
         
		done

	if [ "${InstallerType}" != "App" ] &&
           [ "${InstallerType}" != "gridMath" ]; then

			if [ "${InstallerType}" = "CBM" ]; then
			    xdgScripts="${FullTargetDirectory}/FrontEnd/Resources/X"
			else
			    xdgScripts="${FullTargetDirectory}/SystemFiles/Installation"
			fi

  			if [ -f "${xdgScripts}/xdg-icon-resource" ]; then	

				bitSize="32 64 128"

				if [ "${InstallerType}" = "CBM" ]; then

					for i in ${bitSize}; do
						${xdgScripts}/xdg-icon-resource install --size ${i} ${xdgScripts}/cbm_${i}.png application-vnd.wolfram.cbm
					done

				elif [ "${InstallerType}" = "WSM" ]; then

					for i in ${bitSize}; do
						${xdgScripts}/xdg-icon-resource install --size ${i} ${xdgScripts}/dotmo_${i}.png application-vnd.wolfram.mo
						${xdgScripts}/xdg-icon-resource install --size ${i} ${xdgScripts}/dotmo_${i}.png application-vnd.wolfram.moe
						${xdgScripts}/xdg-icon-resource install --size ${i} ${xdgScripts}/dotsma_${i}.png application-vnd.wolfram.sma
						${xdgScripts}/xdg-icon-resource install --size ${i} ${xdgScripts}/dotsme_${i}.png application-vnd.wolfram.sme

						${xdgScripts}/xdg-icon-resource install --context mimetypes --size ${i} \
							${xdgScripts}/SystemModeler_${i}.png wolfram-systemmodeler
					done

					mimeFiles="vnd.wolfram.mo vnd.wolfram.moe vnd.wolfram.sma vnd.wolfram.sme"

				else

					if [ "${InstallerType}" = "Math" ]; then
						iconResourceName='wolfram-mathematica'

					elif [ "${InstallerType}" = "WD" -o "${InstallerType}" = "WPL" ]; then
						iconResourceName=wolfram-`echo ${InstallerType} | tr '[:upper:]' '[:lower:]'`

					elif [ "${InstallerType}" = "CDF" -o "${InstallerType}" = "PlayerPro" ]; then
						iconResourceName='wolfram-player'

					else
						iconResourceName='wolfram-wolframlanguage'
					fi					
					
					for j in ${bitSize}; do
						if [ -f "${FullTargetDirectory}/SystemFiles/FrontEnd/SystemResources/X/App-${j}.png" ]; then
							${xdgScripts}/xdg-icon-resource install --size ${j} \
								${FullTargetDirectory}/SystemFiles/FrontEnd/SystemResources/X/App-${j}.png ${iconResourceName}
						fi
					done

					docStrings="vnd.wolfram.nb vnd.wolfram.player vnd.wolfram.cdf vnd.wolfram.mathematica.package vnd.wolfram.wl"

			 		for j in ${bitSize}; do
						for d in ${docStrings}; do
							if [ -f "${FullTargetDirectory}/SystemFiles/FrontEnd/SystemResources/X/${d}-${j}.png" ]; then
				   				${xdgScripts}/xdg-icon-resource install --context mimetypes --size ${j} \
					  				${FullTargetDirectory}/SystemFiles/FrontEnd/SystemResources/X/${d}-${j}.png application-${d}
							fi
						done
			 		done

					mimeFiles="vnd.wolfram.cdf vnd.wolfram.mathematica.package vnd.wolfram.nb vnd.wolfram.player vnd.wolfram.wl"
				fi

			fi

        	# Add MIME file type handling
        	xdgCheck mime
        	if [ "${?}" = "0" ]; then
       			if [ -f "${xdgScripts}/xdg-mime" ]; then
                  
           			dirList="/usr/share /usr/local/share"
           			for i in ${dirList}; do
						for m in ${mimeFiles}; do
           					if [ -d "${i}/mime" ] && [ -w "${i}/mime" ]; then
								if [ -f "${xdgScripts}/application-${m}.xml" ]; then
           							${xdgScripts}/xdg-mime install ${xdgScripts}/application-${m}.xml
								fi
           					fi
						done
        			done
				fi

			fi
		fi

		# Install Beagle search support	  
		if [ "${InstallerType}" = "Math" ]; then

			if [ -d "/etc/beagle" -o -d "/usr/etc/beagle" -o -d "/usr/local/etc/beagle" ]; then
				if [ "${isRoot}" = "true" ]; then
					InstallBeagleSearch
				fi
			fi

		fi

		# Install VernierLink .rules file
		rulesDir=/etc/udev/rules.d
		if [ -f ${xdgScripts}/wolfram-vernierlink-libusb.rules ] && [ -w ${rulesDir} ]; then
			chmod 0666 ${xdgScripts}/wolfram-vernierlink-libusb.rules
			cp -pf ${xdgScripts}/wolfram-vernierlink-libusb.rules ${rulesDir}
		fi		

		# Install Wolfram Remote Services
		if [ "${InstallerType}" = "gridMath" ]; then
			InstallRemoteServices
		fi
      
	else
		PrintCopyText Error "NoSpaceError"
	fi

	cd "${ExecutionDirectory}"

	# Clean up
	ComponentTarget=""
	ComponentTarget_=""
	ComponentTargetList=""
	Dots_=""
	DotTextWidth_=""
	InfoDir_=""
	InstallInfoFileList=""
	InstallSize=""
	InstallSizeTemp_=""
	TotalDots_=""
	WhiteSpace_=""

	if [ "${DEBUG}" = "true" ]; then
		echo "<< ### Exiting Function: InstallProduct() ### >>"
		echo "<< ### Exiting Function: InstallProduct() ### >>" 1>&2
	fi

}

# ----------------------------------------------------------------------------
# Function: InstallRemotServices()

InstallRemoteServices() {
   if [ "${DEBUG}" = "true" ]; then
       echo "<< ### Function: InstallRemoteServices() ### >>"
       echo "<< ### Function: InstallRemoteServices() ### >>" 1>&2
   fi
         
   if [ "${isRoot}" = "true" -a "${Automatic}" != "true" ]; then
       ans=""
   
       if [ "${Automatic}" = "true" ]; then
	   lgsUser_="wolframgrid"
       else
	   lgsUser_=""
       fi
	  
       InstallRemoteServices_=""
       PasswordsMatch_=""

       if [ `uname -m` = 'x86_64' ]; then
           _origSystemID="${DefaultSystemID}"
           DefaultSystemID="Linux-x86-64"
       fi
		  
       while [ "${ans}" != "y" -a "${ans}" != "n" ]; do
	      PrintCopyText Prompt "RemoteServicesPrompt" "y"
	
	      if [ "${Automatic}" = "false" ]; then
		  read ans
	      else
	          ans=${ans:="y"}
	          echo "${ans}"
	      fi
	      echo ""
              ans=${ans:="y"}
	
              if [ "${ans}" = "n" -o "${ans}" = "N" ]; then
	          return 1
	      fi
       done 

       InstallRemoteServices_="true"
       SelectAccountMethod

       while [ "${userExists_}" -eq "0" -a "${TomcatUser}" = "Create" ]; do
           PrintCopyText Error "AddUserExistsError"
           SelectAccountMethod
       done
		  
       while [ "${userExists_}" != "0" -a "${TomcatUser}" = "Existing" ]; do
              PrintCopyText Error "UserNotFoundError"
              SelectAccountMethod
       done
	       
       if [ "${userExists_}" != "0" -a "${TomcatUser}" = "Create" ]; then 
           while [ "${PasswordsMatch_}" != "true" ]; do
   	          PrintCopyText Prompt "WRSPasswordPrompt" ""
	  
	          if [ "${Automatic}" = "false" ]; then
                      stty -echo
	              read WRSPassword
	              stty echo
	          else
	  	      echo ""
	          fi
		 
	          echo ""

                  PrintCopyText Prompt "PasswordAgain" ""
                  if [ "${Automatic}" = "false" ]; then
                      stty -echo
                      read WRSPassword_
                      stty echo
                  else
                      echo ""
                  fi

                  if [ "${WRSPassword}" = "${WRSPassword_}" ]; then
                      PasswordsMatch_="true"
                  else
                      echo ""
                      PasswordsMatch_="false"
                      PrintCopyText Error "PasswordError"
                  fi
             done
             echo ""
		 
	     EncWRSPassword=`perl -e 'print crypt($ARGV[0], "password")' "${WRSPassword}"`
	     /usr/sbin/useradd -c "Wolfram Remote Services user" -p "${EncWRSPassword}" "${lgsUser_}" 1>&2

	     if [ "${?}" != "0" ]; then
	         PrintCopyText Error "AddUserError"
		 echo "${CopyText_}" 1>&2
		 sigint="false"
		 CleanUpOnDirtyExit_
	     fi  
       fi
	   
       # Change file ownership to tomcat user
       chown -hR "${lgsUser_}" "${TargetDirectory}" 1>&2
       if [ "${?}" != "0" ]; then
	   PrintCopyText Error "ChownError"
	   echo "${CopyText_}" 1>&2
	   sigint="false"
	   CleanUpOnDirtyExit_
       fi
	   
       # Customize and install wolframlightweithgrid script to /etc/init.d
       InitSourceScript="${TargetDirectory}/SystemFiles/RemoteServices/SystemFiles/Unix/wolframlightweightgrid"
       InitDestinationScript="/etc/init.d/wolframlightweightgrid"
	   
       sed "s/nobody/${lgsUser_}/g;s/SYSTEM_ID=Linux/SYSTEM_ID=${DefaultSystemID}/g" "${InitSourceScript}" | 
       sed "s|${DefaultTargetDirectory}|${TargetDirectory}|g" > "${InitDestinationScript}"
       
       # Set INSTALL_ROOT to TargetDirectory in wrs.sh script file
       WrsScript="${TargetDirectory}/SystemFiles/RemoteServices/SystemFiles/Unix/wrs.sh"
       WrsScript_="${TargetDirectory}/SystemFiles/RemoteServices/SystemFiles/Unix/_wrs.sh"
      
       sed "s|INSTALLROOT=/usr/local/Wolfram/gridMathematica/${VersionNumber}|INSTALLROOT=${TargetDirectory}|g" "${WrsScript}" > "${WrsScript_}"

       sed "s|export JAVA_HOME=\$INSTALLROOT/SystemFiles/Java/Linux|export JAVA_HOME=\$INSTALLROOT/SystemFiles/Java/${DefaultSystemID}|g" "${WrsScript_}" > "${WrsScript}"
       chown "${lgsUser_}" "${WrsScript}"

       chmod 755 "${InitDestinationScript}"
       chmod 755 "${WrsScript}"
	   
       if [ "${?}" != "0" ]; then
	   PrintCopyText Error "TomcatError"
	   echo "${CopyText_}" 1>&2
	   sigint="false"
	   CleanUpOnDirtyExit_
       fi
	   
       # Create symlinks in runlevel directories
       if [ -d "/etc/rc3.d" ]; then
	   RcpParent="/etc"
       elif [ -d "/etc/init.d/rc3.d" ]; then
	     RcpParent="/etc/init.d"
       fi
	   
       if [ -z "${RcpParent}" ]; then
	   PrintCopyText Error "RunlevelError"
       else
	   RunLevel="rc2.d rc3.d rc4.d rc5.d"

	   for Dir in ${RunLevel}; do
	      if [ -d "${RcpParent}/${Dir}" ]; then
	          ln -sf /etc/init.d/wolframlightweightgrid "${RcpParent}/${Dir}/S99wolframlightweightgrid"
	          ln -sf /etc/init.d/wolframlightweightgrid "${RcpParent}/${Dir}/K99wolframlightweightgrid"
              fi
           done
       fi
	   
       PasswordsMatch_="null"
	   
       while [ "${PasswordsMatch_}" != "true" ]; do
   	      echo ""
	      PrintCopyText Prompt "WebAdminPasswordPrompt" ""
	  
	      if [ "${Automatic}" = "false" ]; then
	          stty -echo
		  read WebAdminPassword
		  stty echo
	      else
	          echo ""
	      fi
	      echo ""
	   
	      PrintCopyText Prompt "PasswordAgain" ""
		  
	      if [ "${Automatic}" = "false" ]; then
	       	  stty -echo
		  read WebAdminPassword_
	       	  stty echo
	      else
	          echo ""
       	      fi
       		
       	      if [ "${WebAdminPassword}" = "${WebAdminPassword_}" ]; then
       		  PasswordsMatch_="true"
       	      else
       		  echo ""
       		  PasswordsMatch_="false"
       		  PrintCopyText Error "PasswordError"
       	      fi
       done
       echo ""
       
       if [ "${PasswordsMatch_}" = "true" ]; then
           INSTALLROOT="${TargetDirectory}" ; export INSTALLROOT
           JAVA_HOME="${TargetDirectory}/SystemFiles/Java/${DefaultSystemID}"; export JAVA_HOME
           ${TargetDirectory}/SystemFiles/RemoteServices/SystemFiles/Unix/adminutility.sh passwd admin ${WebAdminPassword}
       fi
	   
       # Start tomcat
       /etc/init.d/wolframlightweightgrid start 
    
       PrintCopyText Text "LicenseInstallWRS"

       # Clean up
       DefaultSystemID="${_origSystemID}"
	   
       echo ""
   else
       continue
   fi
	
    # Clean up
    ans=""
    InitDestinationScript=""
    InitSourceScript=""
    RcpParent=""
    WRSPassword=""
	   
    if [ "${DEBUG}" = "true" ]; then
        echo "<< ### Exiting Function: InstallRemoteServices() ### >>"
		echo "<< ### Exiting Function: InstallRemoteServices() ### >>" 1>&2
    fi

}

# ----------------------------------------------------------------------------
# Function: MakeExecLinks()

MakeExecLinks() {
   if [ "${DEBUG}" = "true" ]; then
      echo "<< ### Function: MakeExecLinks() ### >>"
      echo "<< ### Function: MakeExecLinks() ### >>" 1>&2
   fi

   execDir_="Executables"
   if [ "${InstallerType}" = "WSM" ]; then
      execDir_="bin"
      Script_="ModelCenter"
   fi

   ExecScripts_=""
   for Dir in InstallDir; do

      if [ "${InstallDir}" = "NoInstallDirSpecified" ]; then

         if [ -d "${TargetDirectory}/${execDir_}" ]; then

	    	if [ -n "${ExecScriptsList}" ]; then
	       		ExecScripts_="${ExecScriptsList}"
	    	elif [ "${InstallerType}" != "WSM" ]; then 
	   			ExecScripts_=`ls -1 "${TargetDirectory}/${execDir_}"`
	    	else
	   			ExecScripts_="SystemModeler systemmodeler"
            fi

         fi
      else
         if [ -d "${TargetDirectory}/${Dir}/${execDir_}" ]; then

            if [ -n "${ExecScriptsList}" ]; then
	   	       ExecScripts_="${ExecScriptsList}"
	        elif [ "${InstallerType}" != "WSM" ]; then 
               ExecScripts_=`ls -1 "${TargetDirectory}/${Dir}/${execDir_}"`
            else
	           ExecScripts_="SystemModeler systemmodeler"
	        fi

         fi
      fi

      if [ -z "${AllExecScripts}" ]; then
         AllExecScripts="${ExecScripts_}"
      else
         AllExecScripts="${AllExecScripts} ${ExecScripts_}"
      fi
   done

   if [ -n "${AllExecScripts}" ]; then

      GetDirectory "ExecDirectory"

      if [ "${DirectoryOkay_}" = "true" ]; then
         if [ "${MakeExecDirectory}" = "true" ]; then
            mkdir -p "${ExecDirectory}"
         fi

         if [ -n "${ExecDirectory}" ]; then
            ExecDirectory=`cd "${ExecDirectory}"; pwd`
         fi

         ExistingScriptList=""
         ScriptExists=""
         for Script_ in $AllExecScripts; do
            ScriptExists=`ls -1 "${ExecDirectory}" | egrep "^${Script_}$"`
            ExistingScriptList=`echo "${ExistingScriptList} ${ScriptExists}" | tr -s ' ' | sed -e 's/^ //g' | sed -e 's/ $//g'`
         done

         if [ "${ExistingScriptList}" = "" ]; then
            CreatedScriptList=""
            for Dir in $InstallDir; do
               if [ "${InstallDir}" = "NoInstallDirSpecified" ]; then
                  FullTargetDirectory="${TargetDirectory}"
               else
                  FullTargetDirectory="${TargetDirectory}/${Dir}"
               fi
               if [ -d "${FullTargetDirectory}/${execDir_}" ]; then
	              if [ -n "${ExecScriptsList}" ]; then
		  		      ExecScripts_="${ExecScriptsList}"
                  else
                      ExecScripts_=`ls -1 "${FullTargetDirectory}/${execDir_}"`
		          fi
               fi
               for Script_ in $ExecScripts_; do
                  if [ "${InstallerType}" = "WSM" ]; then
               	      ln -sf "${FullTargetDirectory}/${execDir_}/ModelCenter" "${ExecDirectory}/${Script_}"
		          else
                      ln -sf "${FullTargetDirectory}/${execDir_}/${Script_}" "${ExecDirectory}/${Script_}"
		          fi
                  CreatedScriptList="${CreatedScriptList} ${Script_}"
               done
            done
         else
            ModifyOkay="true"
            for Script_ in $ExistingScriptList; do
               if [ ! -w "${ExecDirectory}/${Script_}" \
                  -a ! -h "${ExecDirectory}/${Script_}" ]; then
                  ModifyOkay="false"
               fi
            done
            if [ "${ModifyOkay}" = "true" ]; then

               DisplayExistingScriptList=`echo "${ExistingScriptList}" | sed -e "s/^/'/g" | sed -e "s/$/'/g" | sed -e "s/ /', '/g"`

               SelectionScriptActionList="Overwrite Rename Cancel"
               SelectFromList Single "ScriptAction"

			   if [ "${ScriptAction}" = "Cancel" ]; then
				   return 1
			   fi
               
               if [ "${ScriptAction}" = "Rename" ]; then
                  DefaultAppendToName_=".old"

                  PrintCopyText Prompt "NewScriptNamePrompt" "${DefaultAppendToName_}"
                  if [ "${Automatic}" = "false" ]; then
                     read AppendToName_
                  else
                     echo ""
                  fi
                  echo ""
                  AppendToName_=${AppendToName_:="$DefaultAppendToName_"}
                  for Script_ in $ExistingScriptList; do
                     mv "${ExecDirectory}/${Script_}" "${ExecDirectory}/${Script_}${AppendToName_}"
                  done
               fi
               for Script_ in $ExistingScriptList; do
                  rm -f "${ExecDirectory}/${Script_}"
               done
               CreatedScriptList=""
               for Dir in $InstallDir; do
                  if [ "${InstallDir}" = "NoInstallDirSpecified" ]; then
                     FullTargetDirectory="${TargetDirectory}"
                  else
                     FullTargetDirectory="${TargetDirectory}/${Dir}"
                  fi
                  if [ -d "${FullTargetDirectory}/${execDir_}" ]; then
		             if [ -n "${ExecScriptsList}" ]; then
		                ExecScripts_="${ExecScriptsList}"
		             elif [ "${InstallerType}" != "WSM" ]; then 
              		    ExecScripts_=`ls -1 "${FullTargetDirectory}/${execDir_}"`
					 else
                        ExecScripts_="SystemModeler systemmodeler"
                     fi
                  fi
                  for Script_ in $ExecScripts_; do
                     if [ "${InstallerType}" = "WSM" ]; then
                         ln -sf "${FullTargetDirectory}/${execDir_}/ModelCenter" "${ExecDirectory}/${Script_}"
                     else
               	         ln -sf "${FullTargetDirectory}/${execDir_}/${Script_}" "${ExecDirectory}/${Script_}"
                     fi
                     CreatedScriptList="${CreatedScriptList} ${Script_}"
                  done
               done
            else
               PrintCopyText Error "FileExistsError"
            fi
         fi
      fi
      echo ""

      if [ "${InstallerType}" = "Math" ] ||
		 [ "${InstallerType}" = "CDF" ] || 
		 [ "${InstallerType}" = "WD" ] ||
		 [ "${InstallerType}" = "WPL" ]; then
		  if [ `uname -m` = 'x86_64' ]; then
            _origSystemID="${DefaultSystemID}"
            DefaultSystemID="Linux-x86-64"
         fi

	 MathematicaScriptDir_="${FullTargetDirectory}/SystemFiles/Kernel/Binaries/${DefaultSystemID}"

	 wolframScript="false"
	 WolframScripts='MathematicaScript WolframScript wolframscript'

	 for i in ${WolframScripts}; do
	    if [ "${ExecDirectory}" = '/usr/bin' ]; then
                if [ -e "${ExecDirectory}/wolframscript" ]; then
                    break
                else
                   ln -sf "${MathematicaScriptDir_}/wolframscript" "${ExecDirectory}/${i}"
  		   wolframScript="true"
                fi
            else
                if [ -f "${MathematicaScriptDir_}/wolframscript" ]; then
                    ln -sf "${MathematicaScriptDir_}/wolframscript" "${ExecDirectory}/${i}"
                    wolframScript="true"
	        fi
            fi
         done
	 if [ "${wolframScript}" = "true" ]; then
             CreatedScriptList="${CreatedScriptList} WolframScript wolframscript"
	 fi
      fi
	  DefaultSystemID="${_origSystemID}"

	  if [ "${InstallerType}" != "App" ] &&
		 [ "${InstallerType}" != "gridMath" ]; then
		  if [ "${NoDesktop}" != "true" ]; then
			  BuildDesktopFile
		  fi
      fi
   fi

   DefaultAppendToName_=""
   Dir=""
   DirectoryOkay_=""
   Script_=""
   ScriptExists=""

   if [ "${DEBUG}" = "true" ]; then
        echo "<< ### Exiting Function: MakeExecLinks() ### >>"
        echo "<< ### Exiting Function: MakeExecLinks() ### >>" 1>&2
  fi

}

# ----------------------------------------------------------------------------
# Function: MakeMathPass()

MakeMathPass() {

   if [ "${InstallerType}" = "gridMath" ] ||
      [ "${InstallerType}" = "Math" ] ||
      [ "${InstallerType}" = "PlayerPro" ] || 
 	  [ "${InstallerType}" = "WD" ] ||
	  [ "${InstallerType}" = "WPL" ] &&
      [ "${InstallRemoteServices_}" != "true" ] &&
      [ "${Automatic}" != "true" ]; then 

      ValidPasswordExists=""
      for TestSystemID in ${DefaultSystemID}; do
            
         if [ -n "`echo \" ${InstallIDList} \" | \
            grep \" ${TestSystemID} \"`" ]; then

            KernelOutput=`"${ExecDirectory}/MathKernel" -runfirst "Exit[]" &`
            if [ -n "${KernelOutput}" ]; then
               KernelOutput=`echo "${KernelOutput}" | grep 'Enter your password:'`
            else
               ValidPasswordExists="error"
            fi

            if [ "${ValidPasswordExists}" != "error" ]; then
               if [ -z "${KernelOutput}" ]; then
                  ValidPasswordExists="true"
               else
                  ValidPasswordExists="false"
               fi
            fi

            if [ "${DEBUG}" = "true" ]; then
               echo "<< \$ValidPasswordExists set to \"${ValidPasswordExists}\". >>"
               echo "<< \$TestSystemID set to \"${TestSystemID}\". >>"
            fi

            break
         fi

      done

      if [ "${DEBUG}" = "true" ]; then
         echo "<< \$TestSystemID set to \"${TestSystemID}\". >>"
      fi

      if [ "${ValidPasswordExists}" = "false" ]; then

         ValidOption="false"

         while [ "${ValidOption}" != "true" ]; do

            PrintCopyText Text "MathpassIntroductionText"

            PrintCopyText Text "MathpassFirstSelectionText"

			if [ "${InstallerType}" = "PlayerPro" ]; then
			
            	PrintCopyText Text "MathpassSecondSelectionTextPlayer"
            	
            else
            
            	PrintCopyText Text "MathpassSecondSelectionText"
            	
            	PrintCopyText Text "MathpassThirdSelectionText"
            	
            fi

            DefaultAction=1
            PrintCopyText Prompt "MathpassActionPrompt" "${DefaultAction}"

            read Action
            echo ""

            Action=${Action:="$DefaultAction"}

            if [ -n "`echo \"${Action}\" | grep '[^0-9]'`" ]; then
               PrintCopyText Error "NumericInputExpectedError"
            elif [ -n "`echo \"${Action}\" | awk '{print $2}'`" ]; then
               PrintCopyText Error "SingleInputError"
            elif [ "${Action}" = "1" ]; then
               ValidOption="true"
               Action="Single"
            elif [ "${Action}" = "2" ]; then
            	if [ "${InstallerType}" = "PlayerPro" ]; then
            		Action="Later"
            	else
            		Action="Network"
            	fi
               ValidOption="true"
            elif [ "${Action}" = "3" ]; then
            	if [ "${InstallerType}" = "PlayerPro" ]; then
            		Item=${Action}
               		PrintCopyText Error "ItemNotFoundError"
               	else
               		ValidOption="true"
               		Action="Later"
               	fi
            else
               Item=${Action}
               PrintCopyText Error "ItemNotFoundError"
            fi

         done

         if [ -z "${TestSystemID}" \
            -a "${Action}" = "Single" ]; then

            PrintCopyText Error "PleaseRunKernelError"

         elif [ "${Action}" = "Single" ]; then
            if [ ! -x "${ExecDirectory}/MathKernel" ]; then
               PrintCopyText Error "KernelNotFoundError"
            else
               PrintCopyText Text "ConfiguringPasswordText"
               "${ExecDirectory}/MathKernel" -run "Exit[]"
            fi
         elif [ "${Action}" = "Network" ]; then
            ServerName=""
            while [ -z "${ServerName}" ]; do
               PrintCopyText Prompt "LicenseServerPrompt" ""
               read ServerName
               echo ""
            done
            mathpass="${TargetDirectory}/Configuration/Licensing/mathpass"
            mkdir -p "${TargetDirectory}/Configuration/Licensing"
            PrintCopyText Text "ConfiguringNetworkPasswordText"
            echo "!${ServerName}" >> "${mathpass}"
         fi
      elif [ "${ValidPasswordExists}" = "true" ]; then
         PrintCopyText Text "ValidMathpassFoundText"
      else # ValidPasswordExists = error
         PrintCopyText Error "RunningMathKernelError"
         exit
      fi
   fi

}

# ----------------------------------------------------------------------------
# Function: OrderList()

OrderList() {

   ListToSort="${1}"

   InitialList=`eval echo '${'${ListToSort}'}'`

   SortedList=""

   DefaultHead="${2}"

   for Item in ${DefaultHead}; do

      Item=`echo "${InitialList}" | tr ' ' '\n' | \
         grep "^${Item}$" | tr '\n' ' '`
      Item=`echo "${Item}" | sed -e 's/^ //g' | \
         sed -e 's/ $//g'`

      InitialList=`echo "${InitialList}" | tr ' ' '\n' | \
         grep -v "^${Item}$" | tr '\n' ' '`

      SortedList="${SortedList} ${Item}"
   done

   SortedList=`echo "${SortedList} ${InitialList}" | \
      tr -s ' ' | sed -e 's/^ //g' | sed -e 's/ $//g'`

   eval "${ListToSort}=\"${SortedList}\""

   DefaultHead=""
   InitialList=""
   ListToSort=""
   SortedList=""

}

# ----------------------------------------------------------------------------
# Function: ParseInput()

ParseInput() {
   Input="$@"

   Verbose="false"
   DEBUG="false"
   Silent="false"
   Automatic="false"
   NoDesktop="false"

   DefaultTargetDirectory=""
   DefaultInstallerLanguage=`echo "${GreetingFile}" | \
      tr '.' ' ' | awk '{print $2}'`
   DefaultLanguage="${DefaultInstallerLanguage}"
   InstallerLog=""

   i=1
   Option=`echo "${Input}" | sed -e 's/^-//' | \
      eval \`echo "awk 'BEGIN { FS=\" -\" } { print $"${i}" }'"\``

   while [ -n "${Option}" ]; do
      InputType=""
      InputVar="Junk"
      case "${Option}" in
         auto)
            Automatic="true"
            ;;
         createdir=*)
            InputVar="ans"
            ;;
         debug)
            DEBUG="true"
            Verbose="true"
            ;;
         execdir=*)
            InputVar="ExecDirectory"
            ;;
         help)
            PrintHelpScreen
            ;;
         installerlanguage=*)
            InputVar="InstallerLanguage"
            InputType="Single"
            ;;
         language=*)
            InputVar="InstallLanguage"
            InputType="Single"
            ;;
         method=*)
            InputVar="InstallFeature"
            ;;
         nodesktop)
            NoDesktop="true"
            ;;
         overwrite=*)
            InputVar="Overwriteans"
            ;;
         platforms=*)
            InputVar="InstallIDList"
            ;;
         products=*)
            InputVar="InstallProductList"
            ;;
         selinux=*)
            InputVar="SELinux"
            ;;
         silent)
            Silent="true"
            Automatic="true"
            InstallerLog="/tmp/InstallerLog-$$"
            exec 1>"${InstallerLog}"
            ;;
         targetdir=*)
            InputVar="TargetDirectory"
            ;;
         verbose)
            Verbose="true"
            ;;
         *)
            PrintCopyText Error "BadOptionError"
            PrintHelpScreen
            ;;
      esac

      OptionInput="`echo \"${Option}\" | awk 'BEGIN { FS=\"=\" } { print $2 }' | tr ',' ' '`"

      eval "${InputVar}=\"${OptionInput}\""

      ItemCount=`echo \`eval echo '${'${InputVar}'}'\` | wc -w`

      if [ "${InputType}" = "Single" -a ${ItemCount} -gt 1 ]; then
         Option=`echo "${Option}" | awk 'BEGIN { FS=\"=\" } { print $1 }'`
         PrintCopyText Error "SingleOptionExpectedError"
         echo "${CopyText_}" 1>&2
         sigint="false"
         CleanUpOnDirtyExit_
      fi
      i=`expr ${i} + 1`
      
      Option=`echo "${Input}" | sed -e 's/^-//' | \
      eval \`echo "awk 'BEGIN { FS=\" -\" } { print $"${i}" }'"\``
      
   done

   if [ "${Automatic}" = "true" ]; then
      TermWidth=80
   else
      TermWidth=`stty -a | tr ';' '\n' | grep 'columns' | tr ' ' '\n' | grep '[1-9]' 2>/dev/null` 
      if [ -z "${TermWidth}" ]; then
         TermWidth=80
      fi
   fi

   if [ -n "`echo ${TermWidth} | grep '[^0-9]'`" ]; then
      TermWidth=80
   fi

   if [ ${TermWidth} -lt 50 ]; then
      TermWidth=50
   fi

   TWmin=`expr ${TermWidth} - 5`

   # clear the screen before we go on
   if [ "${DEBUG}" != "true" -a "${Silent}" != "true" ]; then
      clear
   fi

   i=""
   ItemCount=""
   Input=""
   InputType=""
   InputVar=""
   Junk=""
   Option=""
   OptionInput=""

   if [ "${DEBUG}" = "true" ]; then
      echo "<< ### Exiting Function: ParseInput() ### >>"
      echo "<< ### Exiting Function: ParseInput() ### >>" 1>&2
   fi

}

# ----------------------------------------------------------------------------
# Function: PrintCopyText()

PrintCopyText() {
   if [ "${DEBUG}" = "true" ]; then
      echo "<< ### Function: PrintCopyText() ### >>"
      echo "<< ### Function: PrintCopyText() ### >>" 1>&2
   fi

   CopyTextType_="${1}"
   
   InputFile="Installer${1}"
   InputFile=`eval echo '${'${InputFile}'}'`

   CopyText_=`awk '/:::'"${2}"':::/ {getline; while (substr($1,1,3) != ":::") {print; getline}}' < "${InputFile}"`

   PromptDefault_="${3}"

   CopyText_=`eval echo "\"${CopyText_}\""`

   case "${CopyTextType_}" in
   "Error")
      if [ "${DefaultSystemID}" = "MacOSX" ]; then
         echo "${CopyText_}" | fmt ${TWmin} ${TermWidth}
      else
         echo "${CopyText_}" | fmt -${TermWidth}
      fi
      echo "";;
   "Prompt")
      if [ "${DefaultSystemID}" = "MacOSX" ]; then
         echo "${CopyText_}" | fmt ${TWmin} ${TermWidth}
      else
         echo "${CopyText_}" | fmt -${TermWidth}
      fi
      echo ${n} "> ${c}";;
   "Text")
      if [ "${CopyText_}" != "" ]; then
         if [ "${DefaultSystemID}" = "MacOSX" ]; then
            echo "${CopyText_}" | fmt ${TWmin} ${TermWidth}
         else
            echo "${CopyText_}" | fmt -${TermWidth}
         fi
         echo ""
      fi;;
   "Title")
      TitleWidth_=`echo "${CopyText_}" | wc -c`
      ExtraBannerSpace_=`expr ${TermWidth} - ${TitleWidth_}`
      Spacing_=`expr ${ExtraBannerSpace_} / 2`
      WhiteSpace_=`printf "%-${Spacing_}s"`
      echo "${WhiteSpace_}${CopyText_}";;
   "Verbose")
      if [ "${DefaultSystemID}" = "MacOSX" ]; then
         echo "<< ${CopyText_} >>" | fmt ${TWmin} ${TermWidth}
      else
         echo "<< ${CopyText_} >>" | fmt -${TermWidth}
      fi;;
   esac

   # Clean up
   CopyTextType_=""
   PromptDefault_=""
   TitleWidth_=""
   ExtraBannerWidth_=""
   Spacing_=""
   WhiteSpace_=""

   if [ "${DEBUG}" = "true" ]; then
      echo "<< ### Exiting Function: PrintCopyText() ### >>"
      echo "<< ### Exiting Function: PrintCopyText() ### >>" 1>&2
   fi

}

# ----------------------------------------------------------------------------
# Function: PrintHelpScreen()

PrintHelpScreen() {
   if [ "${DEBUG}" = "true" ]; then
      echo "<< ### Function: PrintHelpScreen() ### >>"
      echo "<< ### Function: PrintHelpScreen() ### >>" 1>&2
   fi

   Help="true"

   InstallerText="${InstallerPath}/TextResources/${DefaultInstallerLanguage}/Text"

   if [ "${DEBUG}" = "true" ]; then
      echo "InstallerText set to ${InstallerText}"
   fi

   PrintCopyText Text "HelpScreenText"

   if [ "${DEBUG}" = "true" ]; then
      echo "<< ### Exiting Function: PrintHelpScreen() ### >>"
      echo "<< ### Exiting Function: PrintHelpScreen() ### >>" 1>&2
   fi

   exit

}

# ----------------------------------------------------------------------------
# Function: PrintIntroduction()

PrintIntroduction() {
   if [ "${DEBUG}" = "true" ]; then
      echo "<< ### Function: PrintIntroduction() ### >>"
      echo "<< ### Function: PrintIntroduction() ### >>" 1>&2
   fi

   # fail if $ProductTitle is not defined.
   if [ -z "${ProductTitle}" ]; then
      echo "CRITICAL FAILURE: PrintIntroduction() Error"
      echo "  \$ProductTitle not defined."
      echo "Critical failure in PrintIntroduction." 1>&2
      sigint="false"
      CleanUpOnDirtyExit_
   fi

   # fail if $FullProductName is not defined.
   if [ -z "${FullProductName}" ]; then
      echo "CRITICAL FAILURE: PrintIntroduction() Error"
      echo "  \$FullProductName not defined."
      echo "Critical failure in PrintIntroduction." 1>&2
      sigint="false"
      CleanUpOnDirtyExit_
   fi

   # fail $TermWidth is not defined.
   if [ -z "${TermWidth}" ]; then
      echo "CRITICAL FAILURE: PrintIntroduction() Error"
      echo "  \$TermWidth not defined."
      echo "Critical failure in PrintIntroduction." 1>&2
      sigint="false"
      CleanUpOnDirtyExit_
   fi

   Line_=`printf "%-${TermWidth}s" | tr ' ' '-'`

   echo "${Line_}"
   PrintCopyText Title "InstallerTitleText"
   echo "${Line_}"
   echo ""

   PrintCopyText Text "CopyrightText"

   # clean up
   Line_=""

   if [ "${DEBUG}" = "true" ]; then
      echo "<< ### Exiting Function: PrintIntroduction() ### >>"
      echo "<< ### Exiting Function: PrintIntroduction() ### >>" 1>&2
   fi

}

# ----------------------------------------------------------------------------
# Function: SelectAccountMethod()

SelectAccountMethod() {
   if [ "${DEBUG}" = "true" ]; then
      echo "<< ### Function: SelectAccountMethod() ### >>"
      echo "<< ### Function: SelectAccountMethod() ### >>" 1>&2
   fi

   defaultUser_="wolframgrid"
   lgsUser_=""
   userExists_="0"

   # Create, or use existing user account as web user Linux only
     SelectionTomcatUserList="Create Existing"
     SelectFromList Single "TomcatUser"

     if [ "${TomcatUser}" = "Existing" ]; then
         id "${defaultUser_}" > /dev/null 2>&1

         if [ "${?}" -eq "0" ]; then
             PrintCopyText Prompt "UserAccountExistPrompt" "${defaultUser_}"
         else
             defaultUser_=""
             PrintCopyText Prompt "UserAccountPrompt" ""
         fi
      else
           PrintCopyText Prompt "UserAccountCreatePrompt" "${defaultUser_}"
      fi

      if [ "${Automatic}" = "false" ]; then
          read lgsUser_
      else
          echo ""
      fi

      echo ""
      lgsUser_=${lgsUser_:="$defaultUser_"}

      egrep -i "^${lgsUser_}:" "/etc/passwd" > /dev/null 2>&1
      [ $? -eq "0" ] && id ${lgsUser_} > /dev/null 2>&1
      [ $? -eq "0" ] && [ ${userExists_} = "0" ] || userExists_=1

      if [ "${DEBUG}" = "true" ]; then
          echo "<< ### Exiting Function: SelectAccountMethod() ### >>"
          echo "<< ### Exiting Function: SelectAccountMethod() ### >>" 1>&2
      fi

}

# ----------------------------------------------------------------------------
#   SelectFromList routine

SelectFromList() {
   if [ "${DEBUG}" = "true" ]; then
      echo "<< ### Function: SelectFromList() ### >>"
      echo "<< ### Function: SelectFromList() ### >>" 1>&2
   fi

   InputType="${1}"
   
   VarToSelect="${2}"

   SelectedItem=""

   SelectionList=`eval echo '${Selection'${VarToSelect}'List}'`
   
   if [ "${InputType}" = "Multi" ]; then
      OutputVar="${VarToSelect}List"
   else
      OutputVar="${VarToSelect}"
   fi

   if [ "${Automatic}" = "true" ]; then
      Output=`eval echo '${'${OutputVar}'}'`

      if [ "${InstallerType}" = "Math" ] ||
         [ "${InstallerType}" = "PlayerPro" ] ||
         [ "${InstallerType}" = "CDF" ] || 
		 [ "${InstallerType}" = "WD" ] ||
		 [ "${InstallerType}" = "WPL" ] &&
         [ `echo "${Output}" | awk '{print length}'` -gt 0 ]; then
         if [ `eval echo "${Output}" | tr '[:upper:]' '[:lower:]'` = "all" ]; then 
            Output="${IDList}"
	     fi
      fi
      
   else
      Output=""
   fi

   if [ "${Output}" = "" ]; then

      while [ -z "${SelectedItem}" ]; do

         ListLength=`echo ${SelectionList} | wc -w`

         if [ ${ListLength} -gt 1 ]; then
            DisplayList="true"
         elif [ ${ListLength} -eq 1 ]; then
            DisplayList="false"
         fi
         
         if [ "${DisplayList}" = "true" ]; then
         	if [ ${ListLength} -gt 1 ]; then
            	PrintCopyText Text "${VarToSelect}IntroductionText"
            fi
            i=1
            for Item in ${SelectionList}; do
               Item=`echo "${Item}" | sed -e 's/:::/ /g'`

       	       if [ "${InstallerType}" = "Math" \
					-o "${InstallerType}" = "WD" \
					-o "${InstallerType}" = "WPL" ]; then
                  case "${Item}" in
                     Linux|Linux-x86-64)
                     	if [ "${InstallerType}" = "CDF" \
                     	   	-o "${InstallerType}" = "PlayerPro" ]; then
                        	Item="Linux x86 (32-bit)"
                        else
                        	Item="Linux x86 (32-bit and 64-bit)"
                        fi;;
                     *)
                        ;;
                  esac
               fi
               
               if [ "${InstallerType}" = "gridMath" ]; then
               	  case "${Item}" in
               	  	 Create)
               	  	   Item="Create a local account (Recommended) 

      Use this option to create a new user account on this computer. 
      This allows you to configure security settings specifically for Mathematica.
";;
               	  	 Existing)
               	  	   Item="Use an existing account

      Use this option if you want to use a network user account or an existing local account.
";; 
               	  	 *)
               	  	    ;;
               	  esac
               fi
               
               echo "  (${i}) ${Item}"
               i=`expr ${i} + 1`
            done
            echo ""
            DefaultItem=1
            SelectionPrompt="${VarToSelect}Prompt"
            PrintCopyText Prompt "${SelectionPrompt}" "${DefaultItem}"
            if [ "${Automatic}" = "false" ]; then
               read ItemSelection
            else
               echo ""
            fi
            echo ""
            Selections=${ItemSelection:="$DefaultItem"}
            Selections=`echo ${Selections} | tr ',' ' ' | \
               tr ' ' '\n' | sort | uniq | tr '\n' ' '`
            InputLength=`echo ${Selections} | wc -w`
            InvalidSelection=`echo ${Selections} | \
                tr ' ' '\n' | grep '[^0-9]'`
            if [ "${InvalidSelection}" != "" ]; then
               PrintCopyText Error "NumericInputExpectedError"
               SelectedItem=""
            elif [ "${InputType}" = "Multi" ]; then
               SelectedList=""
               for Item in ${Selections}; do
                  SelectedItem=`echo ${SelectionList} | tr ' ' '\n' | sed "${Item}p;d"`
                  if [ "${SelectedItem}" = "" ]; then
                     PrintCopyText Error "ItemNotFoundError"
                  else
                     SelectedList=`eval echo "${SelectedItem} ${SelectedList}"`
                  fi
               done
               SelectedItem="${SelectedList}"
            elif [ "${InputType}" = "Single" -a ${InputLength} -gt 1 ]; then
               PrintCopyText Error "SingleInputError"
               SelectedItem=""
            elif [ "${InputType}" = "Single" ]; then
               Item=`eval echo "${Selections}"`
                SelectedItem=`echo "${SelectionList}" | \
                  tr ' ' '\n' | sed "${Item}p;d"`
               if [ "${SelectedItem}" = "" ]; then
                  PrintCopyText Error "ItemNotFoundError"
               fi
            fi
         else
            if [ "${VarToSelect}" = "InstallID" ]; then
               SelectedItem="None ${SelectionList}"
            else
               SelectedItem="${SelectionList}"
            fi
         fi
      done
   else
      ListOkay="1"
      for Item in ${Output}; do
         CheckItem=`echo "${SelectionList}" | grep "${Item}"`
         if [ "${CheckItem}" = "" ]; then
            ListOkay="0"
            PrintCopyText Error "Bad${VarToSelect}Error"
            echo "${CopyText_}" 1>&2
            sigint="false"
            CleanUpOnDirtyExit_
         fi
      done
      SelectedItem="${Output}"
   fi

   if [ "${VarToSelect}" = "InstallID" ]; then
      SelectedItem=`echo "None ${SelectedItem}" | tr ' ' '\n' | \
         sort | uniq | tr '\n' ' '`
   fi

   eval "${OutputVar}=\"${SelectedItem}\""

   if [ "${DEBUG}" = "true" ]; then
      echo "<< ${OutputVar} set to `eval echo '${'${OutputVar}'}'` >>"
   fi

   # Clean up
   CheckItem=""
   DefaultItem=""
   DisplayList=""
   InputType=""
   Item=""
   ListLength=""
   ListOkay=""
   Output=""
   OutputVar=""
   SelectedItem=""
   SelectionList=""
   Selections=""
   VarToSelect=""

   if [ "${DEBUG}" = "true" ]; then
      echo "<< ### Exiting Function: SelectFromList() ### >>"
      echo "<< ### Exiting Function: SelectFromList() ### >>" 1>&2
   fi

}

# ----------------------------------------------------------------------------
#   SelectInstallerLanguage routine

SelectInstallerLanguage() {
   if [ "${DEBUG}" = "true" ]; then
      echo "<< ### Function: SelectInstallerLanguage() ### >>"
      echo "<< ### Function: SelectInstallerLanguage() ### >>" 1>&2
   fi

   SelectionInstallerLanguageList=`ls -1 "${InstallerPath}/TextResources" \
                | grep -v '^Greeting'`

   SelectFromList Single "InstallerLanguage"

   InstallerTitle="${InstallerPath}/TextResources/${InstallerLanguage}/Text"
   InstallerText="${InstallerPath}/TextResources/${InstallerLanguage}/Text"
   InstallerError="${InstallerPath}/TextResources/${InstallerLanguage}/Error"
   InstallerPrompt="${InstallerPath}/TextResources/${InstallerLanguage}/Prompt"
   InstallerVerbose="${InstallerPath}/TextResources/${InstallerLanguage}/Verbose"

   if [ ! -f "${InstallerTitle}" -o ! -f "${InstallerText}" \
      -o ! -f "${InstallerPrompt}" -o ! -f "${InstallerError}" ]; then
      echo "CRITICAL FAILURE: Fundamental Error"
      echo " Installer text not found."
      echo "Critical Failure in SelectInstallerLanguage." 1>&2
      sigint="false"
      CleanUpOnDirtyExit_
   fi

   if [ "${DEBUG}" = "true" ]; then
      echo "<< ### Exiting Function: SelectInstallerLanguage() ### >>"
      echo "<< ### Exiting Function: SelectInstallerLanguage() ### >>" 1>&2
   fi

}

# ---------------------------------------------------------------------------
#   TraverseDirectory routine

TraverseDirectory() {
    if [ "${DEBUG}" = "true" ]; then
       echo "<< ### Function: TraverseDirectory() ### >>"
       echo "<< ### Function: TraverseDirectory() ### >>" 1>&2
    fi

    ls "${1}" | while read i

    do
       if [ -d "${1}/${i}" ]; then
          chgrp -fh  "${InstallGroup}" "${1}/${i}"
          chown -fh "${InstallUser}" "${2}/${i}"

          TraverseDirectory "${1}/${i}" `expr "${2}" + 1`
       else
	      chgrp -fh "${InstallGroup}" "${i}"
	      chown -fh  "${InstallUser}" "${i}"
       fi
    done

    if [ "${DEBUG}" = "true" ]; then
       echo "<< ### Exiting Function: TraverseDirectory() ### >>"
       echo "<< ### Exiting Function: TraverseDirectory() ### >>" 1>&2
    fi

}

# ---------------------------------------------------------------------------
#   xdg-utils sanity check

xdgCheck() {
    if [ "${DEBUG}" = "true" ]; then
       echo "<< ### Function: xdgCheck() ### >>"
       echo "<< ### Function: xdgCheck() ### >>" 1>&2
    fi

    if [ "${NoDesktop}" = "true" ]; then
        return 1
    fi
    
    util="${1}"
    
    if [ "${util}" = 'mime' ]; then
        xdgDirs="/usr/share/mime /usr/local/share/mime /usr/share/gnome/apps" 
        which kde-config > /dev/null 2>&1; if [ "${?}" = "0" ]; then
            kdeDirs=`kde-config --path mime | sed 's/:/ /g' | awk '{ $1=""; print $0 }'`
            xdgDirs="/usr/share/mime /usr/local/share/mime /usr/share/gnome/apps $kdeDirs"
        fi 
        
    elif [ "${util}" = 'icon' ]; then    
        xdgDirs="/usr/share/icons /usr/local/share/icons"

    elif [ "${util}" = 'desktop' ]; then
        xdgDirs="/usr/share/applications /usr/local/share/applications /usr/share/gnome/apps /usr/share/applink" 
        xdgDirs="${xdgDirs} /etc/xdg/menus/applications-merged"

		# Check for existing system locations.(181164)

		kdeGlobalDir="/usr/share/applnk"
		if [ ! -w $kdeGlobalDir ]; then
			kdeGlobalDir=
		fi

		gnomeGlobalDir="/usr/share/gnome/apps"
		if [ ! -w $gnomeGlobalDir ]; then
			gnomeGlobalDir=
		fi

		globalDirs="$gnomeGlobalDir $kdeGlobalDir"

		xdgSystemDir=/usr/local/share/:/usr/share/
		for x in `echo $xdgSystemDir | sed 's/:/ /g'` ; do
			if [ -w $x/desktop-dirctories ] ; then
				xdgDataDir="$x/desktop-directories"
				break
			fi
		done
		if [ -z "${xdgDataDir}${globalDirs}" ]; then
			return 1
		fi

		xdgSystemDir=/etc/xdg
		for x in `echo $xdgSystemDir | sed 's/:/ /g'` ; do
			if [ -w $x/menus ] ; then
				xdgConfigDir="$x/menus"
				break
			fi
		done
		if [ -z "${xdgConfigDir}${globalDirs}" ]; then
			return 1
		fi
		
    fi
    
    for i in ${xdgDirs}; do
       if [ -d "${i}" ] && [ -w "${i}" ]; then
           return 0
       fi
    done
    
    return 1

    if [ "${DEBUG}" = "true" ]; then
       echo "<< ### Exiting Function: xdgCheck() ### >>"
       echo "<< ### Exiting Function: xdgCheck() ### >>" 1>&2
    fi

}

# ----------------------------------------------------------------------------
#   Set installation directory as MATHEMATICA_HOME environment variable and
#   create .installdirs and .lastinstall files in appropriate location

setHome() {

	if [ "${DEBUG}" = "true" ]; then
		echo "<< ### Function: setHome() ### >>"
		echo "<< ### Function: setHome() ### >>" 1>&2
	fi
	
	if [ ! ${InstallerType} = "CDF" ] && [ ! ${InstallerType} = "PlayerPro" ]; then
		profileDir=/etc/profile.d
		profileTarget=${profileDir}/Mathematica.sh
		# Does /etc/profile.d exist and can the user write to it?	
		if [ -d ${profileDir} ] && [ -w ${profileDir} ]; then
			if [ -f ${profileTarget} ]; then
				mv ${profileTarget} ${profileTarget}.old
			fi
			echo '#!/bin/sh' > ${profileTarget}
			echo export MATHEMATICA_HOME="\"${FullTargetDirectory}\"" >> ${profileTarget}
		fi
	fi
	
	# Create .installdirs and .lastinstall files in the preferences file
	# Can the user write to /usr/share?  
	if [ -w /usr/share ]; then
		if [ ${InstallerType} = CDF ]; then
			usrBase=/usr/share/MathematicaPlayer
		elif [ ${InstallerType} = PlayerPro ]; then
			usrBase=/usr/share/MathematicaPlayerPro
		else
			usrBase=/usr/share/Mathematica
		fi
	
	# If not, set the preferences file to the home directory
	elif [ ! -w /usr/share ] && [ ${isRoot} = false ]; then
		if [ ${InstallerType} = CDF ]; then
			usrBase="$HOME/.MathematicaPlayer"
		elif [ ${InstallerType} = PlayerPro ]; then
			usrBase="$HOME/.MathematicaPlayerPro"
		else
			usrBase="$HOME/.Mathematica"
		fi
	
	# This should never happen, but just in case...
	else 
		return 1
	fi

	usrPath="${usrBase}/Installer"
	usrBaseCreated=false
	usrPathCreated=false
	
	if [ ! -d "${usrBase}" ]; then
		mkdir "${usrBase}"
		usrBaseCreated=true		
	fi
	
	# Check if the installation directory exists
	if [ ! -d "${usrPath}" ]; then
		mkdir "${usrPath}"
		usrPathCreated=true		
	fi
	
	# Append to list of installation directories
	installDirs="${usrPath}/.installdirs"
	installLast="${usrPath}/.lastinstall"
	installPrefs="${installLast} ${installDirs}" 
	homeLine="${InstallerType}	${FullTargetDirectory}	${VersionNumber}"
	
	if [ -d "${usrPath}" ] && [ -w "${usrPath}" ]; then
		
		for installPref in $installPrefs; do
			if [ -f "${installPref}" ]; then
				cp "${installPref}" "${installPref}.old"
			fi
		done
	
		if ! grep -q "${homeLine}" "${installDirs}" > /dev/null 2>&1; then
			echo "${homeLine}" >> "${installDirs}"
		fi
		
		echo "${homeLine}" > "${installLast}"
		
		return 0
	fi
	
	if [ "${DEBUG}" = "true" ]; then
		echo "<< ### Exiting Function: setHome() ### >>"
		echo "<< ### Exiting Function: setHome() ### >>" 1>&2
	fi
	
	return 1
	
}

# ----------------------------------------------------------------------------
#   Check for existence of mDNS services; warn if not presesnt. Do not fail
#   the install if this check does not succeed. Attempt to advise the user
#   on how to provide these services. 

checkAvahiDaemon() {

	if [ "${DEBUG}" = "true" ]; then
		echo "<< ### Function: checkAvahiDaemon() ### >>"
		echo "<< ### Function: checkAvahiDaemon() ### >>" 1>&2
	fi
	
	# We should only care about launch manager on full Mathematica/Wolfram Desktop sessions
	if [ ! ${InstallerType} = "CDF" ] && [ ! ${InstallerType} = "PlayerPro" ]; then 
		# Check if avahi-daemon is present
		if hash avahi-daemon > /dev/null 2>&1; then
			if avahi-daemon -c > /dev/null 2>&1; then
				# Avahi is running, say nothing.
				return 0
			# Does the system use systemd or sysvinit/upstart?
			else
				if hash systemctl > /dev/null 2>&1; then
				# We have systemd
					if systemctl is-active avahi-daemon > /dev/null 2>&1; then
						# We've made some sort of mistake, say nothing.
						return 0
					else
						PrintCopyText Text "AvahiDaemonNotRunning"
						PrintCopyText Text "AvahiDaemonActivateSystemD"
						return 0
					fi
				else
					# assume classic init if systemd is not present
					# print a generic message telling the user to enable avahi-daemon
					PrintCopyText Text "AvahiDaemonNotRunning"
					PrintCopyText Text "AvahiDaemonInit" 
					return 0
				fi
			fi
		else
			PrintCopyText Text "AvahiDaemonNotFound"
			if [ -f /etc/redhat-release ]; then
				# Red Hat distribution
				PrintCopyText Text "AvahiDaemonInstallRedHat"
				return 0
			elif [ -f /etc/debian_version ]; then
				PrintCopyText Text "AvahiDaemonInstallDebian"
				return 0
			else
				PrintCopyText Text "AvahiDaemonInstallGeneric"
				return 0
			fi
		fi
	fi
	
	if [ "${DEBUG}" = "true" ]; then
		echo "<< ### Exiting Function: checkAvahiDaemon() ### >>"
		echo "<< ### Exiting Function: checkAvahiDaemon() ### >>" 1>&2
	fi
	
	return 0	
}

# ----------------------------------------------------------------------------
#   Clean up new profile files on dirty exit or error

cleanHome() {

	if [ "${DEBUG}" = "true" ]; then
		echo "<< ### Function: cleanHome() ### >>"
		echo "<< ### Function: cleanHome() ### >>" 1>&2
	fi

	# Remove new profiles and restore if possible
	preferenceList="${profileTarget} ${installDirs} ${installLast}"
		for Prefs in $preferenceList; do
			if [ -f "${Prefs}" ] && [ -w "${Prefs}" ]; then
				rm -f "${Prefs}"
				if [ -f "${Prefs}.old" ]; then
					mv "${Prefs}.old" "${Prefs}"
				fi
			fi
		done
      
	# Remove the base/version directory if created
	if [ ${usrPathCreated} = true ]; then
		rm -Rf "${usrPath}"
	fi
	# Remove the base directory if created by the installer
	if [ ${usrBaseCreated} = true ]; then
		rm -Rf "${usrBase}"
	fi 
	
	if [ "${DEBUG}" = "true" ]; then
		echo "<< ### Exiting Function: cleanHome() ### >>"
		echo "<< ### Exiting Function: cleanHome() ### >>" 1>&2
	fi
	
	return 0

}

# ----------------------------------------------------------------------------
#   Main installer routine

trap CleanUp_ 0
trap CleanUpOnDirtyExit_ 2

# Make certain that $PATH contains /bin and /usr/bin.
#   /usr/xpg4/bin is for Solaris
#   /usr/contrib/bin is for HP-UX
#   /usr/sbin and /usr/bsd are for IRIX
PATH="/usr/xpg4/bin:/usr/contrib/bin:/bin:/usr/bin:/usr/sbin:/usr/bsd:/usr/local/bin:/usr/ucb"
CMD_ENV="xpg4"
export PATH

# Who and where am I?
ExecutionDirectory=`pwd`
InstallerScript=`basename "${0}"`
InstallerPath=`dirname "${0}"`
InstallerPath=`cd "${InstallerPath}"; pwd`

Initialize
ParseInput "$@"
InfoInitialize
PrintIntroduction

SelectInstallerLanguage

if [ "${InstallerType}" = "CDF" \
	-o "${InstallerType}" = "PlayerPro" ]; then
	PrintCopyText Text "PlayerIntroductionText"
else
	PrintCopyText Text "IntroductionText"
fi

while [ ${SpaceToInstall} != 1 ]; do

   # Get Language to install
   SelectionInstallLanguageList="${LanguageList}"
   SelectFromList Single "InstallLanguage"

   # Get Platform to install for
   SelectionInstallIDList="${IDList}"
   SelectFromList Multi "InstallID"

   # Get Features to install
   SelectionInstallFeatureList="${FeatureList}"
   SelectFromList Single "InstallFeature"

   GetDirectory "TargetDirectory"

   InstallAsRoot
   InstallProduct
done


CopyManPages

if [ "${InstallerType}" != "CBM" ]; then
	MakeExecLinks
else
	BuildDesktopFile
fi

CheckSELinux_
checkAvahiDaemon
setHome
#FindSoundDrivers_

exit 0

