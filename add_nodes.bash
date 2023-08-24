
# get current dir
DIR=$(cd -P -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)

N=$1
for i in `seq $N`; do
    LLsub $DIR/start_worker.bash $2 -- $3 $4 &
    #LLsub /home/gridsan/omoll/seesaw/scripts/start_worker.bash -g volta:1 -s 20 &
    #LLsub /home/gridsan/omoll/seesaw/scripts/start_worker.bash  -s 48  &
done

wait