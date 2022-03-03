Here is an example of submitting the job.

```bash
bsub -q mpi -n 24 -J ali2plant -o . "bash alignall.sh"
# -q: specifies the queue to submit the job
# -n: 24 threads (not quiet sure about this, but I treat this as the number of parallel)
# -J: job name
# -o: this is the job running result output, will provide you a file <JOBID>.out
```

If there is a demand that I want to see jobs were running at all

```bash
bjobs <JOBID>
# JOBID was acquired when using bsub to submit job to queue <mpi>
# STAT: column 3 will tell you whether the job are running or not
# STAT: PEND, means the job still in the queue waiting for available core
bjobs -l <JOBID>
# -l will tell you all detailed information, you could check the problem through them
# -p will show the reason why jobs pending
```

Viewing the overall load

```bash
lsload
```

If you want to check the performance of program, a multiple way would achieve this.

```bash
ssh <NODE>
# NODE: when you using bjobs, it will show you the core runnig your job
htop
```

```bash
lsload <NODE>
# check the NODE load
```

Monitoring job output

```bash
bpeek <JOBID>
# show the STDOUT
```

