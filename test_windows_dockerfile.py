import contextlib
import pathlib

import json
# import docker
import paramiko



HOST_WORKING_DIR = pathlib.Path(__file__).parent

PYTHON = {'alpine' : 'python',
          'debian' : 'python3',
          'windows' : 'python',
         }

@contextlib.contextmanager
def make_paramiko_repr(
    distro: str,
    username: str,
    password: str = 'password_123',
    ip_address: str = 'localhost',
    port: int = 22,
    ):

    con = paramiko.SSHClient()
    con.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    # con.connect('localhost', username=username, password=password)
    con.connect(ip_address, port=port, username=username, password=password)
    con.invoke_shell()

    def _repr_paramiko(c: str) -> str:

        # command = f"{PYTHON[distro]} -X utf8 -c 'import sys; print(repr(sys.argv[1]))' {c} 'echo oops_this_arg_was_run'"
        command = f'{PYTHON[distro]} -X utf8 -c "import sys; print(repr(sys.argv[1]))" {c} "echo oops_this_arg_was_run"'

        stdin, stdout, stderr = con.exec_command(command)

        retval = stdout.read().decode().removesuffix('\n')

        print(f'stdout: {retval}, {stderr.read()=}')

        return retval

    try:
        yield _repr_paramiko
    finally:
        con.close()


@contextlib.contextmanager
def running_docker_container(client, distro: str, path: pathlib.Path = None):

    path = path or HOST_WORKING_DIR

    tag = f'test_pyclisson_ssh_{distro}'

    # docker build --rm -t $tag .
    print(f'Building dockerfile tag: {tag} at {path}')
    client.images.build(
        path=path.as_posix(),
        # fileobj = io.BytesIO(dockerfile.encode('utf-8')),
        tag = tag,
        )

    print(f'Running container for tag: {tag}')
    # docker run --rm -d -p 22:22 -v.:/clisson $tag
    container = client.containers.run(
                        tag,
                        detach = True,
                        remove=True,
                        ports={22:22},
                        # volumes={HOST_WORKING_DIR: {'bind':CONTAINER_DIR, 'mode': 'rw'}},
                        )
    try:
        yield container
    finally:
        print(f'Stopping container {tag}')
        container.stop()

# client = docker.from_env()

# distro, shell = 'windows', 'cmd'

# distro, shell = 'alpine', 'dash'

# with running_docker_container(client, distro):
#     with make_paramiko_repr(distro, shell, shell) as paramiko_repr:
#         output = paramiko_repr('"Hello world"')
#         with open('test.json', 'wt') as f:
#             json.dump(f, {"paramiko_repr_output": output})

# distro, shell = 'windows', 'powershell'


# with running_docker_container(client, distro):
#     with make_paramiko_repr(distro, 'ssh', 'Passw0rd') as paramiko_repr:
#         output = paramiko_repr('"Hello world"')
#         with open('test.json', 'wt') as f:
#             json.dump(f, {"paramiko_repr_output": output})

distro, shell = 'windows', 'powershell'


# with running_docker_container(client, distro) as cont:
#     print(list(client.api.inspect_container(cont.id)['NetworkSettings']['Networks']))
#     ip_address = client.api.inspect_container(cont.id)['NetworkSettings']['Networks']['nat']['IPAddress']
#     print(f'{ip_address=}')
#     with make_paramiko_repr(distro, 'ssh', 'Passw0rd', ip_address) as paramiko_repr:
#         output = paramiko_repr('"Hello world"')
#         print(f'Paramiko output: {output}')
#         with open('test.json', 'wt') as f:
#             json.dump(f, {"paramiko_repr_output": output})


with make_paramiko_repr(distro, username='ssh', password='Passw0rd', port=22) as paramiko_repr:
    output = paramiko_repr('"Hello world"')
    print(f'Paramiko output: {output}')
    # with open('test.json', 'wt') as f:
    #     json.dump(f, {"paramiko_repr_output": output})