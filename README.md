# Home Assistant AMD Pipeline
Run your Home Assistant Voice Control on AMD hardware with ROCm - without spending a fortune on Nvidia cards.

This repository is tested with my **AMD Instinct MI50**. I cannot guarantee it will work with other cards. 
You are more than welcome to make adjustments to try and get it to run - but expect no support from me.

## Warning
As much as I'd like to provide fully functional, readily built images for you to spin up some containers, these images end up being massive and I haven't found a way to automate the build pipeline without exceeding GitHub's space constraints yet.

You'll need to build this yourself for now. I also had trouble getting my MI50 recognized *properly* on Ubuntu 24.04.
The only way the card would initialize was by updating the bootloader under `/etc/default/grub` with `GRUB_CMDLINE_LINUX_DEFAULT="quiet splash pci=realloc pci=noaer pcie_aspm=off iommu=pt"`. Turning off CSM and enabling Above 4G Decoding seemed to be a must too.

You will have to build your own images and follow ROCm docs to get the drivers running your host. 

## Voice to text
Generally, some variation of OpenAI's Whisper is used to achieve this. For now, this repository supports faster-whisper.
But the plan is to support WhisperX and possibly other HA integrations at some point if they are fast and accurate.

Both of these rely on CTranslate2. Unfortunately, there seems [little interest in supporting ROCm](https://github.com/OpenNMT/CTranslate2/issues/1072). Whisper.cpp seems to lack any ROCm support - but Vulkan could work as a fallback.

Luckily enough, there is a [fork of CTranslate2](https://github.com/arlo-phoenix/CTranslate2-rocm) that works with ROCm (for now). It seems semi-maintained and in my limited testing has worked just fine with ROCM 6.3.3.

Unfortunately for us, it requires being built. I've containerized the entire built process according to their instructions.

Navigate to `./faster-whisper/CTranslate2-build` and run `docker compose up`. It may take a while, but the resulting libraries will appear in the `dist` folder. You may store a copy of them, but don't move anything.

Now navigate back to `./faster-whisper`. The resulting image can be used to spin up a container running a Wyoming server that your Home Assistant can easily communicate with. First, build the image via `docker compose build`. This will copy the previously built dependencies into your new image. 

Then consulting the `docker-compose.yml` to choose your model and server port. Start the image via `docker compose up -d`.

## Agent - Local LLM of your choice
It seems the most efficient and most common ways to run an LLM locally and provide an OpenAI-like web API are llamacpp (with Python wrapper), which has native ROCm support or koboldcpp-rocm, which is a well maintained fork.
Ollama also provides a ROCm image and seems to have [native integration for Home Assistant](https://www.home-assistant.io/integrations/ollama/).

In addition to the official Ollama implementation, there are also 2 HACS projects
- [Extended OpenAI Integration](https://github.com/jekalmin/extended_openai_conversation)
- [Home-LLM](https://github.com/acon96/home-llm)

### Extended OpenAI Integration
The former seems a lot more popular. The idea is, that instead of pointing it towards OpenAI and paying for API calls, you would point it towards your Llama.cpp, Ollama or other server that can consume and produce "chat" queries according to OpenAPI's spec.
Since it requires function calling, I tried getting it to work with [Functionary](https://github.com/MeetKai/functionary) as that seems to perform the best.
The only way I had some success was using llama-cpp-python with functionary 2.4 and Extended OpenAI Integration. I could not get it to work with functionary 3.2 via llama.cpp's server.

This is probably due to my lack of experience with function calling and tools in general. So I left the examples in for you to try.

### Home-LLM
Home-LLM has great documentation and a much wider range of support for different backends. There's support for Ollama, llama-cpp-python, OpenAI responses and locally running models.
I've had success with "just" plugging a model of my choice (ideally the one the creator trained) into a llama.cpp server (see my image for it) and connecting to the server. 
Responses have been nearly instant and generally I'd say about 95% of them are interpreted correctly - but I also use a very simple setup for now. 
Even Functionary kind of worked, despite me not adjusting the prompt.

### What's next?
I have yet to mess arouind with Llama, Mistral, Deepseek and QwQ for parsing intent. My prompts are extremely simple and have not been adjusted much at all.
After reading a lot of good things about Functionary, I would love to be able to use it - at the very least to compare it to the others. 
Responses for the smaller models usually took about 3-4 seconds, so I believe it's still within usable territory for a local AI assistant.


## Plans
- build images via build pipeline, even if selfhosted runner is required
- try to reduce the resulting images' size by using a better base image
- consider implications of combining all 3 components into one image