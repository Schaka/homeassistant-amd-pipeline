# Home Assistant AMD Pipeline
Run your Home Assistant Voice Control on AMD hardware with ROCm - without spending a fortune on Nvidia cards.

This repository is tested with my AMD Instinct Mi50. I cannot guarantee it will work with other cards. 
You are more than welcome to make adjustments to try and get it to run- but expect no support from me.

## Warning
As much as I'd like to provide fully functional, readily built images for you to spin up some containers, these images end up being massive and I haven't found a way to automate the build pipeline without exceeding GitHub's space constraints yet.

You'll need to build this yourself for now. I also had trouble getting my Mi50 recognized *properly* on Ubuntu 24.04.
The only way the card would initialize was by updating the bootloader under `/etc/default/grub` with `GRUB_CMDLINE_LINUX_DEFAULT="quiet splash pci=realloc pci=noaer pcie_aspm=off iommu=pt"`. Turning off CSM and enabling Above 4G Decoding seemed to be a must too.

You will have to build your own images and follow ROCm docs to get the drivers running your host. 

## Voice to text
Generally, some variation of OpenAI's Whisper is used to achieve this. For now, this repository supports faster-whisper.
But the plan is to support WhisperX and possibly other HA integrations at some point if they are fast and accurate.

Both of these rely on CTranslate2. Unfortunately, there seems [little interest in supporting ROCm](https://github.com/OpenNMT/CTranslate2/issues/1072). Whisper.cpp seems to lack any ROCm support - but Vulkan could work as a fallback.

Luckily enough, there is a [fork of CTranslate2](https://github.com/arlo-phoenix/CTranslate2-rocm) that works with ROCm (for now). It seems semi-maintained and in my limited testing has worked just fine with ROCM 6.3.3.

Unfortunately for us, it requires being built. I've containerized the entire built process according to their instructions.

Navigate to `./faster-whisper/CTranslate2-build` and run `docker compose up`. It may take a while, but the resulting libraries will appear in the `dist` folder. You may store a copy of them, but don't move anything.

Now navgiate back to `./faster-whisper`. The resulting image can be used to spin up a container running a Wyoming server that your Home Assistant can easily communicate with. First, build the image via `docker compose build`. This will copy the previously built dependencies into your new image. 

Then consulting the `docker-compose.yml` to choose your model and server port. Start the image via `docker compose up -d`.

## Agent - Local LLM of your choice
It seems the most efficient and most common ways to run an LLM locally and provide an OpenAI-like web API are llamacpp (with Python wrapper), which has native ROCm support or koboldcpp-rocm, which is a well maintained fork. 

Going with the natively supported option seemed like a no-brainer to me, but I lack experience in this field and if performance is left on the table that way, I may add both images as an option here.


## Intent detection - Functionary
TODO

## Plans
- build images via build pipeline, even if selfhosted runner is required
- try to reduce the resulting images' size by using a better base image
- improve efficiency and speed by relying less on Pyton/PyTorch (existing images) but more native apps
- consider implications of combining all 3 components into one image