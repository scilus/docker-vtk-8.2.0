# docker-vtk-8.2.0
Docker for VTK 8.2.0 with Mesa for offscreen rendering

Build commands:

Before build the Docker: sudo docker image rm vtk-8.2.0:docker

To build the Docker: sudo docker build . -t "vtk-8.2.0:docker"

Dependencies versions:

    VTK: 8.2.0
    mesa: 11.0.7
