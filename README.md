
DISCLAIMER - ABANDONED/UNMAINTAINED CODE / DO NOT USE
=======================================================
While this repository has been inactive for some time, this formal notice, issued on **December 10, 2024**, serves as the official declaration to clarify the situation. Consequently, this repository and all associated resources (including related projects, code, documentation, and distributed packages such as Docker images, PyPI packages, etc.) are now explicitly declared **unmaintained** and **abandoned**.

I would like to remind everyone that this project’s free license has always been based on the principle that the software is provided "AS-IS", without any warranty or expectation of liability or maintenance from the maintainer.
As such, it is used solely at the user's own risk, with no warranty or liability from the maintainer, including but not limited to any damages arising from its use.

Due to the enactment of the Cyber Resilience Act (EU Regulation 2024/2847), which significantly alters the regulatory framework, including penalties of up to €15M, combined with its demands for **unpaid** and **indefinite** liability, it has become untenable for me to continue maintaining all my Open Source Projects as a natural person.
The new regulations impose personal liability risks and create an unacceptable burden, regardless of my personal situation now or in the future, particularly when the work is done voluntarily and without compensation.

**No further technical support, updates (including security patches), or maintenance, of any kind, will be provided.**

These resources may remain online, but solely for public archiving, documentation, and educational purposes.

Users are strongly advised not to use these resources in any active or production-related projects, and to seek alternative solutions that comply with the new legal requirements (EU CRA).

**Using these resources outside of these contexts is strictly prohibited and is done at your own risk.**

This project has been transfered to Makina Corpus <freesoftware@makina-corpus.com> ( https://makina-corpus.com ). This project and its associated resources, including published resources related to this project (e.g., from PyPI, Docker Hub, GitHub, etc.), may be removed starting **March 15, 2025**, especially if the CRA’s risks remain disproportionate.

# Docker based image for solr

## USE/Install with makina-states
- makina-state deployment (legacy) can be found in .salt


## corpusops/solr (CURRENT)
### Description
This setups a nginx reverse proxy on http/https that forward requests
to an underlying solr worker.


### ajust some system conf

Mostly for solr5+

- System wide

    ```sh
    sudo sysctl -w vm.max_map_count=262144
    ```

- Or by docker CLI setting if possible

    ```
    --sysctl vm.max_map_count=262144
    ```

### Volumes
- We use two main volumes!
    - a volume ``setup`` to share a configuration file to reconfigure fles
    - a volume ``data`` to store user data

#### Initialise setup volume
- To reconfigure any setting upon container (re)start, create/edit ``/setup/reconfigure.yml``
    - See [defaults](/ansible/roles/solr/defaults/main.yml)

- exemple:

    ```sh
    mkdir -p local/setup
    cat >local/setup/reconfigure.yml << EOF
    ---
    cops_es_env:
      SOLR_HTTP_PORT: 9200
    EOF
    ```

- to enable/disable the nginx vhost:

    ```
    # cops_solr_has_reverse_proxy: false
    ```

### Run this image through docker
- To pull & run this image
  Note that The folllowing command implicitly create 2 volumes against local directories and the goal
  is to prepopulate the directories from the image content on the first run.<br/>
  Indeed, the -v option does not feed host directories, even if empty from an image content.

    ```sh
    # docker pull corpusops/solr:<TAG>
    docker pull corpusops/solr:5.4.0
    docker run \
      --name=my-solr-container \
      -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
      -v "$(pwd)/local/setup:/setup:ro" \
      -v "$(pwd)/local/data:/srv/projects/solr/data" \
      --security-opt seccomp=unconfined \
      -P -d -i -t corpusops/solr:5.4.0
    ```

- In development, you can add the following knob to indicate that you want to
  edit files.

    ```sh
    -e SUPEREDITORS=$(id -u)
    ```

### Build this image
- Install ``hashicorp/packer`` && ``docker``
- get the code
- run ``./bin/build.sh``

### Image provision notes
- See ``.ansible``, the image is (re)-configured using ansible.

### A note on file rights
- Docker file rights are a nightmare for developers
- We provide a very way to use, specially when you are on localhost,<br/>
  activly developping  your app to edit the files of the container,<br/>
  thanks to POSIX ACLS.
- You need two things to configure your app (normally good by dedfault):
    - ``cops_solr_supereditors_paths`` Tell which paths will be "opened" to the outside user(s) if default does not suit your need
    - ``cops_solr_supereditors`` Tell which user(s), (attention **UIDS**).<br/>
      The aforementioned command to launch container includes the ``SUPEREDITORS`` env var configured with the loggued in user
- Those settings can be overriden via ``/setup/reconfigure.yml``
- File rights are enforced upon container (re-)start
- If file rights are messed up too much, you can try this to enforce them

    ```sh
    docker exec -e SUPEREDITORS="$(id -u)" -ti <mycontainer> bash
    /srv/projects/<myproject>/fixperms.sh
    ```

## ansible
- Docker uses the [solr role](ansible/roles/solr) underthehood which
  is generic and is not docker specific.
- You may use directly this role to provision solr on another host type.

### Steps to create cops docker compliant images
- We use via  bin/build.sh which launch [docker_build_chain](https://github.com/corpusops/corpusops.bootstrap/blob/master/hacking/docker_build_chain.py) ([doc](https://github.com/corpusops/corpusops.bootstrap/blob/master/doc/docker_build_chain.md#sumup-steps-to-create-corpusops-docker-compliant-images))


