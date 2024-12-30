# Docker Setup

Use docker engine (not through docker desktop) since docker desktop doesn't have GPU support for Linux yet.

1. Install docker engine from [here](https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository)
2. Add user to `docker` group, sign out and sign in again.
3. Install NVIDIA container toolkit from [here](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html)

This should run

```bash
docker run --rm --runtime=nvidia --gpus all ubuntu nvidia-smi
```

If it doesn't work, set `no-cgroups = false` in `/etc/nvidia-container-runtime/config.toml` (from [here](https://stackoverflow.com/a/78137688/5836037))
