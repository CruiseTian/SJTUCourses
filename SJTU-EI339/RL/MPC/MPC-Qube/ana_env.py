import gym
import argparse
from dynamics import *
from controller import *
from utils import *
from quanser_robots.common import GentlyTerminating

# env_id = "BallBalancerSim-v0"
env_id = "Qube-100-v0"
env = GentlyTerminating(gym.make(env_id))
anylize_env(env)