To build a particular target you have to edit
new/.git/settings.mk.
Change the first 2 lines:
PREFIX         = /pkg/suse12/software/pitchfork/09112017-foss-2017a-bax2bam
WORKDIR        = /pkg/suse12/build/pitchfork/09112017/foss-2017a-bax2bam/pitchfork/workspace
so that the target - in this case bax2bam - occurs in the two paths

