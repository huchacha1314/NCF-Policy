#!/bin/bash
#获取传入的数据 1 GPU设备号/2 随机数种子/3 缓存目录/4 训练模型策略
GPUS=$1
SEED=$2
CACHE=$3
POLICY=$4
# 将除此以外的参数传入 EXTRA_ARGS
array=( $@ )#将所有的参数保存到数组中
len=${#array[@]}
EXTRA_ARGS=${array[@]:4:$len}#获取从第五个参数开始的所有参数
EXTRA_ARGS_SLUG=${EXTRA_ARGS// /_}

echo extra "${EXTRA_ARGS}"#使用 echo 打印额外参数，以便在脚本执行时查看传入的参数

echo "Training single mug"
# echo policy "${POLICY}"

# LAUNCHER="basic"
# 单纯的先赋值给LAUNCHER
LAUNCHER="faircluster"

if [ "${POLICY}" == "proprio" ]; then
    echo "Running proprio only"
    CUDA_VISIBLE_DEVICES=${GPUS} \
    python3.8 NCFgym/isaacgymenvs/train_cluster.py -m \
     task=NCFTaskMugCupholderPlaceTacto \
     headless=True \ # True 表示在没有图形界面的环境中执行
     seed=${SEED} \
     launcher=${LAUNCHER} \ # 运行 ./launcher/faircluster.yaml faircluster 可能表示分布式训练
     num_envs=256 \
     task.sim.sim_digits=False \
     train.ppo.tactile_info=False \
     train.ppo.ncf_info=False \
     task.rl.orientation_penalty_scale=0.1 \
     train.algo=PPO2 \
     train.ppo.multi_gpu=False \
     train.ppo.minibatch_size=512 \
     train.ppo.output_name=cupholder_proprio_only/"${CACHE}" \
     ${EXTRA_ARGS}

elif [ "${POLICY}" == "tactile" ]; then
    echo "Running proprio + tactile"
    python3.8 NCFgym/isaacgymenvs/train_cluster.py -m \
     task=NCFTaskMugCupholderPlaceTacto \
     headless=True \
     seed=${SEED} \
     num_envs=256 \
     pipeline=gpu \
     launcher=${LAUNCHER} \
     task.sim.sim_digits=True \
     task.rl.compute_contact_gt=False \
     task.rl.orientation_penalty_scale=0.1 \
     train.algo=PPO2 \
     train.ppo.tactile_info=True \
     train.ppo.ncf_info=False \
     train.ppo.minibatch_size=512 \
     train.ppo.output_name=cupholder_proprio_tactile/"${CACHE}" \
     ${EXTRA_ARGS}

elif [ "${POLICY}" == "proprio_gt" ]; then
    echo "Running proprio + gt contact"
    CUDA_VISIBLE_DEVICES=${GPUS} \
    python3.8 NCFgym/isaacgymenvs/train_cluster.py -m \
     task=NCFTaskMugCupholderPlaceTacto \
     headless=True \
     seed=${SEED} \
     launcher=${LAUNCHER} \
     num_envs=256 \
     task.rl.orientation_penalty_scale=0.1 \
     task.sim.sim_digits=False \
     task.rl.max_episode_length=250 \
     task.rl.compute_contact_gt=True \
     task.rl.world_ref_pointcloud=True \
     train.algo=PPO2 \
     train.ppo.multi_gpu=False \
     train.ppo.normalize_point_cloud=True \
     train.ppo.ncf_info=True \
     train.ppo.ncf_use_gt=True \
     train.ppo.minibatch_size=512 \
     train.ppo.output_name=cupholder_proprio_gt_norm/"${CACHE}" \
     ${EXTRA_ARGS}

elif [ "${POLICY}" == "proprio_ncf" ]; then
    echo "Running proprio + ncf contact"
    CUDA_VISIBLE_DEVICES=${GPUS} \
    python3.8 NCFgym/isaacgymenvs/train_cluster.py -m \
     task=NCFTaskMugCupholderPlaceTacto \
     headless=True \
     seed=${SEED} \
     launcher=${LAUNCHER} \
     num_envs=256 \
     task.rl.orientation_penalty_scale=0.1 \
     task.sim.sim_digits=True \
     task.rl.max_episode_length=250 \
     task.rl.compute_contact_gt=False \
     task.rl.world_ref_pointcloud=True \
     task.ncf.ncf_arch=transformer \
     task.ncf.ncf_epoch=19 \
     train.algo=PPO2 \
     train.ppo.multi_gpu=False \
     train.ppo.normalize_point_cloud=True \
     train.ppo.ncf_info=True \
     train.ppo.ncf_use_gt=False \
     train.ppo.minibatch_size=512 \
     train.ppo.output_name=cupholder_proprio_ncf_norm/"${CACHE}" \
     ${EXTRA_ARGS}

elif [ "${POLICY}" == "proprio_ncf_v2" ]; then
    echo "Running proprio + ncf_v2 contact"
    CUDA_VISIBLE_DEVICES=${GPUS} \
    python3.8 NCFgym/isaacgymenvs/train_cluster.py -m \
     task=NCFTaskMugCupholderPlaceTacto \
     headless=True \
     seed=${SEED} \
     launcher=${LAUNCHER} \
     num_envs=256 \
     task.rl.orientation_penalty_scale=0.1 \
     task.sim.sim_digits=True \
     task.rl.max_episode_length=250 \
     task.rl.compute_contact_gt=False \
     task.rl.world_ref_pointcloud=True \
     task.ncf.ncf_arch=transformer_v2 \
     task.ncf.checkpoint_vae=checkpoints_all/digit_vae/digit_vae_mugs.ckpt \
     task.ncf.ncf_epoch=19 \
     train.algo=PPO2 \
     train.ppo.multi_gpu=False \
     train.ppo.normalize_point_cloud=True \
     train.ppo.ncf_info=True \
     train.ppo.ncf_use_gt=False \
     train.ppo.minibatch_size=512 \
     train.ppo.output_name=cupholder_proprio_ncf_v2_norm/"${CACHE}" \
     ${EXTRA_ARGS}

elif [ "${POLICY}" == "proprio_ncf_m1" ]; then
    echo "Running proprio + ncf_m1"
    CUDA_VISIBLE_DEVICES=${GPUS} \
    python3.8 NCFgym/isaacgymenvs/train_cluster.py -m \
     task=NCFTaskMugCupholderPlaceTacto \
     headless=True \
     seed=${SEED} \
     launcher=${LAUNCHER} \
     num_envs=256 \
     task.rl.orientation_penalty_scale=0.1 \
     task.sim.sim_digits=True \
     task.rl.max_episode_length=250 \
     task.rl.compute_contact_gt=False \
     task.rl.world_ref_pointcloud=False \
     task.ncf.ncf_arch=transformer_m1 \
     task.ncf.ncf_epoch=19 \
     train.algo=PPO2 \
     train.ppo.multi_gpu=False \
     train.ppo.normalize_point_cloud=True \
     train.ppo.ncf_info=True \
     train.ppo.ncf_use_gt=False \
     train.ppo.minibatch_size=512 \
     train.ppo.output_name=cupholder_proprio_ncf_m1_centric_norm/"${CACHE}" \
     ${EXTRA_ARGS}

elif [ "${POLICY}" == "ncf_adapt" ]; then
    echo "Running ncf transformer adaptation"
    CUDA_VISIBLE_DEVICES=${GPUS} \
    python3.8 NCFgym/isaacgymenvs/train_cluster.py -m \
     task=NCFTaskMugCupholderPlaceTacto \
     headless=True \
     seed=${SEED} \
     launcher=${LAUNCHER} \
     num_envs=256 \
     checkpoint=/private/home/carohiguera/NCF_RL/outputs_pc/cupholder_proprio_gt_contact/v2/stage1_nn/best_reward_-10.45.pth \
     task.rl.orientation_penalty_scale=0.1 \
     task.sim.sim_digits=True \
     task.rl.max_episode_length=250 \
     task.rl.compute_contact_gt=True \
     task.rl.world_ref_pointcloud=True \
     task.ncf.ncf_arch=transformer \
     task.ncf.ncf_epoch=19 \
     train.algo=ProprioAdapt2 \
     train.ppo.multi_gpu=False \
     train.ppo.normalize_point_cloud=False \
     train.ppo.ncf_info=True \
     train.ppo.ncf_use_gt=False \
     train.ppo.ncf_proprio_adapt=True \
     train.ppo.minibatch_size=512 \
     train.ppo.output_name=cupholder_ncf_adapt/"${CACHE}" \
     ${EXTRA_ARGS}

fi
