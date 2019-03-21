from cmd import Cmd
import requests


class bcolors(object):
    HEADER = "\033[95m"
    OKBLUE = "\033[94m"
    OKGREEN = "\033[91m"
    WARNING = "\033[93m"
    FAIL = "\033[91m"
    ENDC = "\033[0m"
    BOLD = "\033[1m"
    UNDERLINE = "\033[4m"


def record_history(func):
    def wrapper(self, args):
        func(self, args)
        self.history.append(f"{func.__name__.replace('do_', '')} {args}")
    return wrapper


class JRPC(object):
    def __init__(self, url="http://localhost:4000", session=requests):
        self.url = url
        self.session = session
        self.session_id = 0

    def remote_call(self, method_name, *args, **kwargs):
        payload = {"method": method_name, "jsonrpc": "2.0", "id": self.session_id}
        if args:
            payload["params"] = args
        elif kwargs:
            payload["params"] = kwargs

        result = self.session.post(self.url, json=payload)
        try:
            json_result = result.json()
        except Exception as e:
            print(result)
            print(result.text)
            raise
        id = json_result.get("id")
        if id != self.session_id:
            raise ValueError(
                "JSON RPC Error expected id {}, but got {} instead".format(
                    self.session_id, id
                )
            )
        self.session_id += 1
        return json_result

    def __getattr__(self, name):
        return lambda *args, **kwargs: self.remote_call(name, *args, **kwargs)


class RemoteDebuggerControl(Cmd):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.jrpc = JRPC()
        self.history = []
        print(
            f"Welcome to Pharo remote command line debugger (session on {self.jrpc.url})"
        )

    def do_exit(self, inp):
        """Exit the remote debugger control"""
        print("Bye")
        return True

    do_EOF = do_exit
    help_EOF = do_exit.__doc__

    def do_connect(self, url):
        """Connects to a remote debugger"""
        self.jrpc = JRPC(url=url)
        print("Remote url set to", url)
        try:
            print(">>>", requests.get(url).text)
        except Exception:
            print("Unable to contact the remote URL")

    def do_eval(self, expression):
        """Evaluate an expression on the remote server"""
        try:
            json_response = self.jrpc.evaluate(expression)
            print(json_response["result"])
        except KeyError as e:
            print("Evaluation raised in the Pharo image")
            error = json_response["error"]["data"]
            print(bcolors.FAIL)
            print(">>", error["tag"])
            print(">>", error["signalerContext"])
            print(bcolors.ENDC)
        except Exception as e:
            print("Evaluation raised an exception", e)

    do_e = do_eval

    def do_echo(self, arg):
        try:
            json_response = self.jrpc.echo(arg)
            print(json_response["result"])
        except KeyError as e:
            print(json_response)
        except Exception as e:
            print("Unable to perform echo", e)

    @record_history
    def do_init(self, inp):
        try:
            json_response = self.jrpc.initialize(inp)
            self.display_line(json_response["result"])
        except KeyError as e:
            print(json_response)
        except Exception as e:
            print("Unable to perform the init", e)
            print(json_response)

    @staticmethod
    def display_line(line_info):
        source = line_info["source"].replace("\r", "\n")
        start = line_info["start"] - 1
        stop = line_info["stop"]
        new_source = (
            source[:start]
            + bcolors.OKGREEN
            + bcolors.BOLD
            + bcolors.UNDERLINE
            + source[start:stop]
            + bcolors.ENDC
            + source[stop:]
        )
        print(">>>", new_source)

    @record_history
    def do_step(self, inp):
        try:
            json_response = self.jrpc.step()
            self.display_line(json_response["result"])
        except KeyError as e:
            print(json_response)
        except Exception as e:
            print("Unable to perform the step", e)

    do_s = do_step

    @record_history
    def do_next(self, inp):
        try:
            json_response = self.jrpc.next()
            self.display_line(json_response["result"])
        except KeyError as e:
            print(json_response)
        except Exception as e:
            print("Unable to perform the next", e)

    do_n = do_next

    @record_history
    def do_next_stmt(self, inp):
        try:
            json_response = self.jrpc.nextStatement()
            self.display_line(json_response["result"])
        except KeyError as e:
            print(json_response)
        except Exception as e:
            print("Unable to perform the next stmt", e)

    def do_display(self, inp):
        try:
            json_response = self.jrpc.display()
            self.display_line(json_response["result"])
        except KeyError as e:
            print(json_response)
        except Exception as e:
            print("Unable to perform the display", e)
            print(json_response)

    def do_list(self, arg):
        try:
            json_response = self.jrpc.list()
            processes = json_response["result"]["processes"]
            for process in processes:
                print(f"""[{process['hash']}] {process['string']}""")
        except KeyError as e:
            print(json_response)
        except Exception as e:
            print("Unable to perform the list", e)

    def do_debug(self, arg):
        try:
            json_response = self.jrpc.debug(processHash=int(arg))
            self.display_line(json_response["result"])
        except KeyError as e:
            print(json_response)
        except Exception as e:
            print("Unable to init the debug session", e)

    def do_continue(self, arg):
        try:
            json_response = self.jrpc.resume()
            self.display_line(json_response["result"])
        except KeyError as e:
            print(json_response)
        except Exception as e:
            print("Unable to continue execution", e)
            print(json_response)

    do_c = do_continue

    def do_history(self, arg):
        if arg == '':
            print('\n'.join(self.history))
        elif arg.startswith('save'):
            fname =  arg.split()[-1]
            with open(fname, 'w') as f:
                f.write('\n'.join(self.history))
                f.close()
        elif arg.startswith('load'):
            fname =  arg.split()[-1]
            with open(fname, 'r') as f:
                fl = f.readlines()
                for line in fl:
                    self.history.append(line)
                f.close()
        elif arg == 'clean':
            self.history.clear()


    def do_currentcontext(self, arg):
        try:
            json_response = self.jrpc.currentcontext()
            print(json_response["result"])
        except KeyError as e:
            print(json_response)
        except Exception as e:
            print("Unable to ask for current context", e)
            print(json_response)

    def default(self, inp):
        self.do_eval(inp)


RemoteDebuggerControl().cmdloop()
