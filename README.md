Build the Docker image:

```console
% PROJECT=$(basename `pwd`) && docker image build -t $PROJECT-image . --build-arg user_id=`id -u` --build-arg group_id=`id -g`
```

Run the Docker container:

```console
% docker container run -d --rm --init --mount type=bind,src=`pwd`,dst=/app --name $PROJECT-container $PROJECT-image
```

Run the following commands inside the Docker containers as needed:

```console
% uv run examples/cow.py
```

Select **[Dev Containers: Attach to Running Container](https://code.visualstudio.com/docs/devcontainers/attach-container#_attach-to-a-docker-container)** through the **Command Palette (Shift + Command + p)**

Finally, Open the `/app`.
