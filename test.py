class A:
    def echo(self):
        print('call a.echo')

class B(A):
    def echo(self):
        super().echo()
        print('call b.echo')

class C(A):
    def echo(self):
        super().echo()
        print('call c.echo')

class D(C,B):
    def echo(self):
        super().echo()
        print('call d.echo')

print(B.__mro__)
print(C.__mro__)
print(D.__mro__)

c = C()
c.echo()
print('------------')
d = D()
d.echo()

