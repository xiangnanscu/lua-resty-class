class B:
    def __init__(self):
        self.name = 'B'

    def echo(self):
        print('call b.echo, ', self.name)

class C(B):
    def __init__(self):
        super().__init__()
        self.name = 'C'

    def echo(self):
        super().echo()
        print('call c.echo, ', self.name)

    def c_method(self):
        print('this is c_method')

# D is defined but not used or extended, so it's not clear what its purpose is.
# If needed, it could be defined similarly to B, C, or E.

class E:
    def __init__(self):
        self.name = 'E'

    def echo(self):
        print('call e.echo, ', self.name)

    def e_method(self):
        print('this is e_method')

# F and G are supposed to inherit from both C and E. In Python, this is done
# through multiple inheritance.
class F(C, E):
    def __init__(self):
        super().__init__()
        self.name = 'F'

class G(C, E):
    def __init__(self):
        super().__init__()
        self.name = 'G'

    def echo(self):
        super().echo()
        print('call g.echo, ', self.name)

    def g_method(self):
        print('this is g_method')

f = F()
f.echo()


g = G()
g.echo()
