# Linguagem Go/GoLang
## Origens e Influências
 
Em 2007, Rob Pike, Ken Thompson e Robert Griesemer criaram a linguagem de programação Go como um projeto interno da Google em resposta a alguns problemas enfrentados por eles durante o desenvolvimento de sistemas que trabalhassem com a sua infraestrutura. Estes problemas surgiram a partir do uso de processadores multinúcleos, sistemas distribuídos em redes, computação massiva e modelo de computação web, que apesar de tornar a computação muito mais potente, também agregou uma série de complexidades.
Em novembro de 2009 a linguagem foi lançada como um projeto de código aberto (Open Source).

Durante a experiência de 30 anos com a linguagem C criaram uma linguagem capaz de ser sua sucessora. Como em C, Go mostra a sua força na programação de sistemas, embora a linguagem possa ser implementada para praticamente qualquer finalidade.

O objetivo da empresa era obter uma linguagem que pudesse unir a velocidade de desenvolvimento  e simplicidade de linguagens dinâmicas (Python), com a performance e segurança de linguagens compiladas (C ou C++) e  com eficiência e confiabilidade de linguagens como Java.

Outra característica era que o Go tivesse uma sintaxe consistente e que não deixasse margem para dúvidas, diferente de Perl, Ruby ou Scala que usam uma variedade de construções sintáticas ou métodos para um único e mesmo propósito.

Além disso, Go é considerado “leve” em termos de uso de memória. 

## Primitivas de Concorrência

Concorrência é um dos fatores mais fortes da linguagem, se você precisar sobrecarregar um backend com diversos processamentos simultâneos, os goroutines, channels e select auxiliam nesta tarefa. 
Obs: Programação concorrente aumenta o desempenho, pois aumenta-se a quantidade de tarefas sendo executadas em determinado período de tempo.

### Goroutines

A definição de Goroutine é bem simples: Goroutine é uma função que é capaz de ser executada simultaneamente com outras funções, ou seja, de forma concorrente. Os Goroutines são similares as threads em C.

Para executer:
```shell
$ go run <Arquivo>.go
```

Arquivo.go:

```go
package main

import "fmt"
func f(from string) {
    for i := 0; i < 3; i++ {
        fmt.Println(from, ":", i)
    }
}
func main() {    
    f("direct")  
    go f("goroutine")
    go func(msg string) {
       fmt.Println(msg)
     }("going")
   var input string
    fmt.Scanln(&input)
    fmt.Println("done")
}
```

Saída possível:

direct : 0

direct : 1

direct : 2

goroutine : 0

going

goroutine : 1

goroutine : 2


done

#### Em C

Para executar o mesmo código em C, precisamos usar e gerenciar pthreads, o código abaixo executa uma rotina parecida com o código em go, mas executa as threads em série e não é possível criar funções aninhadas em C.

Para compilar (pthread é uma biblioteca dinâmica): 

```bash
    gcc -pthread <Arquivo Fonte>.c -o <NomeDoExecutável>
```

Arquivo Fonte.c:

```c
#include <stdio.h>
#include <string.h>
#include <pthread.h>
#include <stdlib.h>
#include <unistd.h>

pthread_t tid[2];

void* notGoroutineClone(void* arg)
{
    char* str = arg;

    for(int i = 0; i < 3; i++)
        printf("%s %d\n", str, i);

    return NULL;
}

void* notNestedFunction(void* arg)
{
    char* str = arg;

    printf("%s\n", str);

    return NULL;
}

int main()
{
    int err;

    notGoroutineClone("direto ");

//  Temos que salvar o endereço de memória da thread
    pthread_create(&(tid[0]), NULL, &notGoroutineClone, "nao e goroutine ");
    if (err != 0)
        printf("\nThread 1 deu errado :[%s]", strerror(err));

    pthread_create(&(tid[1]), NULL, &notNestedFunction, "não é possível aninhar funcao em c ¯\\_(ツ)_/¯");
    if (err != 0)
        printf("\nThread 2 deu errado :[%s]", strerror(err));

    sleep(5);
    return 0;

}
```

Saída:

direto  0

direto  1

direto  2

nao e goroutine  0

nao e goroutine  1

nao e goroutine  2

não é possível aninhar funcao em c ¯\_(ツ)_/¯

#### Em Python

É possível executar threads em python do mesmo modo que em go, mas a quantidade de linhas de código é maior e é necessário criar uma classe de thread para gerenciar as threads.

Para executar:
```bash
$ python <Nome do arquivo>.py
```

Nome do arquivo.py:

```python
from threading import Thread
import thread
import threading

class Th(Thread):
    def __init__ (self, string):
        Thread.__init__(self)
        self.string = string

    def run(self):
        for i in range(0, 2):
            print "%s : %d" % (self.string, i)

class FuncThread(threading.Thread):
    def __init__(self, target, *args):
        self._target = target
        self._args = args
        threading.Thread.__init__(self)
 
    def run(self):
        self._target(*self._args)

direto = Th("direto")
direto.run()

pythonThread = Th("pythonThread")
pythonThread.start()

def indo(string):
    print string

indoThread = FuncThread(indo, "indo")
indoThread.start()
indoThread.join()
```

Saída:

direto : 0

direto : 1

pythonThread : 0

pythonThread : 1

indo


ou

direto : 0

direto : 1

indo

pythonThread : 0

pythonThread : 1



### Channels

Channels em Go são utilizados para fazer com que duas Goroutines se comuniquem e para sincronizar a execução de seus códigos. 
package main

Para executar:
```bash
$ go run <Arquivo>.go 
ping
```

Arquivo.go:

```go
import "fmt"

func main() {
    messages := make(chan string)

    go func() { messages <- "ping" }()
    msg := <-messages
    fmt.Println(msg)
}
```

Saída:

ping

#### Em C

Para simularmos um comportamento parecido em C, devemos usar pthread_join e uma variável passada por referência.

```bash
    gcc -pthread <Arquivo Fonte>.c -o <NomeDoExecutável>
```

Arquivo Fonte.c:

```c
#include <stdio.h>
#include <string.h>
#include <pthread.h>
#include <stdlib.h>

void * channel(void *arg)
{

    strcpy((char *)arg, "ping");
}


int main(void)
{
    pthread_t  th;
    char str[50];

    (void) pthread_create(&th, NULL, &channel, str);

    (void ) pthread_join(th, NULL);

    printf("%s\n", str);

    return 0;
}
```

Saída:

ping

#### Em Python

Em Python, existe uma biblioteca multiprocessing que possui uma classe capaz de gerenciar processos assíncronos, por isso, para um efeito parecido com o channel do go, basta usar a classe ThreadPool.

Para executar:
```bash
$ python <Nome do arquivo>.py
```

Nome do arquivo.py:

```python
def channel():
  return 'ping'

from multiprocessing.pool import ThreadPool
pool = ThreadPool(processes=1)

async_result = pool.apply_async(channel) # tuple of args for foo

return_val = async_result.get()  # Retorna o valor de channel

print return_val
```

Saída: 

ping

### Select

O select do Go permite que você espere em múltiplos canais de operações. Combinar goroutines e canais com o select é um dos poderosos recursos da linguagem Go.
O select é similar a um switch-case, sua função é receber ou enviar dados com múltiplos canais.

Para executer:
```shell
$ go run <Arquivo>.go
```

Arquivo.go:
```go
package main
import "time"
import "fmt"
func main() {    
    c1 := make(chan string)
    c2 := make(chan string)
    go func() {
        time.Sleep(time.Second * 1)
       c1 <- "one"
    }()
    go func() {
       time.Sleep(time.Second * 2)
        c2 <- "two"
    }()   

 for i := 0; i < 2; i++ {
        select {
        case msg1 := <-c1:
            fmt.Println("received", msg1)
       case msg2 := <-c2:
            fmt.Println("received", msg2)
        }
    }
```

Saída:

received one

received two

#### Em C e Python

O comportamento do switch de concorrência é muito complexo para ser reproduzido em outras linguagens, pois não basta aguardar as threads terminarem de executar, o switch, na realidade, executa parte do código de acordo com a ordem de término das threads concorrentes, exigindo um gerenciamento enorme em outras linguagens.

## Características da linguagem

Um workspace é uma hierarquia de diretórios com três diretórios em sua raiz:

* src — contém os arquivos de código fonte Go organizado em pacotes (um pacote por diretório).
* pkg — contém os arquivos objetos dos pacotes.
* bin — contém os programas gerados, os arquivos executáveis.

A ferramenta go compila os códigos fontes dos pacotes e instala os binários resultantes nos diretórios pkg e bin.
Adicionando Workspace
Por padrão, a linguagem Go define como seu caminho de Workspace $HOME/go, mas é possível adicionar novos caminhos de Workspace.
### Windows

Adicionar $GOPATH às var. de ambiente: 
Meu computador : Propriedades : Configurações avançadas : Variáveis de ambiente : Variáveis do sistema :
    $GOPATH=<Adicionar caminho aqui>

Adicionar $GOPATH/bin ao path:
    export PATH=$PATH:$GOPATH/bin
### Linux

Para adicionar $GOPATH às variáveis de ambiente, basta editar o arquivo ~/.bashrc e adicionar a linha:
export GOPATH=$GOPATH:<Adicionar caminho aqui>
Para adicionar a pasta bin ao $GOPATH, adicione ao ~/.bashrc também:
    export PATH=$PATH:$GOROOT/bin:$GOPATH/bin
Após fazer as alterações, é necessário sinalizá-las para o terminal:
    source ~/.bashrc

## Gerenciamento de módulos e pacotes

A linguagem Go se propõe a lidar com o gerenciamento de dependências de bibliotecas externas de maneira mais eficiente e simples em relação à outras linguagens.

### Imports

Para definir que um pacote será usado, assim como em outras linguagens, devemos usar o comando import seguido do pacote que será usado. Em go, os imports podem ser usados para resolver dependências automaticamente por meio de um gerenciador de dependências. 
Por exemplo, se precisarmos da biblioteca de gerenciamento de url (mux), basta inserirmos ao início do código:

```go
import “github.com/gorilla/mux’”
```

O gerenciador de pacotes será responsável por baixar e adicionar o pacote “mux” ao seu projeto. Para realizar a importação em si e a adição do pacote à estrutura de arquivos, usamos um gerenciador de dependências, o que torna go uma linguagem mais simples de ser implementada.

### Gerenciador de dependência *dep*

No ecossistema Go existem várias implementações de gerenciamento de dependências e pacotes, o que poderia gerar um certo conflito na hora de selecionar uma solução. Para resolver isso a comunidade começou a desenvolver uma ferramenta para ser o padrão das próximas versões da linguagem. Esta ferramenta é o dep.
O dep ainda está em desenvolvimento, mas já é considerado funcional pelo site oficial do mesmo.
Para acoplar a funcionalidade do dep à sua IDE Go, basta executar no prompt/terminal:

```bash
go get -u github.com/golang/dep/cmd/dep
```

A seguir, caso não tenha adicionado $GOPATH/bin às suas variáveis de ambiente, é necessário instalar o binário. Para isso, deve-se seguir até o diretório onde a ferramenta foi baixada e executando o comando “install”:

```bash
cd $GOPATH/src/github.com/golang/dep
go install
```

https://github.com/golang/dep/issues/847

Após instalado, para resolver as dependências de um projeto, basta abrir a pasta do projeto e entrar com o comando:
    
```bash
dep init
```
    
Este comando irá analisar os arquivos .go contidos no diretório src, procurando pelos import e ao encontrá-lo ele fez os seguintes passos:
cria um diretório chamado vendor
faz o go get de cada dependência, salvando os arquivos no vendor
cria um arquivo chamado Gopkg.toml com as definições das dependências
cria um arquivo chamado Gopkg.lock com os detalhes das versões instaladas, incluindo o commit específico que está sendo usado de cada dependência

Caso alguma dependência nova seja adicionada, basta executar o comando dep ensure e as dependências serão atualizadas.

```bash
dep ensure
```

## O conceito de OO em Go

Em go não existe orientação a objeto, ao menos não seguindo o padrão já conhecido. Go não possui classes, objetos, exceções nem modelos. Ela tem, porém, coletor de lixo e concorrência embutidos. A omissão mais aparente, em relação a orientação a objetos, é que não há hierarquia de tipos em Go. 


### Características da OO em Go

Go não tem classes, mas possui métodos e tipos, sendo um deles, as estruturas.Estruturas são definidas pelo usuário, e ao serem utilizadas com os métodos, são semelhantes às classes de outras linguagens

### Estruturas

A estrutura armazena apenas o estado, e não possui comportamento, ou seja, possui apenas os atributos.

Ex.: Exemplo de estrutura 
https://code.tutsplus.com/pt/tutorials/lets-go-object-oriented-programming-in-golang--cms-26540

### Métodos

Os métodos são funções que operam em tipos específicos. A partir de uma cláusula receptador, é possível indicar em que tipo objeto eles operam.

Ex.: Exemplo de método
https://code.tutsplus.com/pt/tutorials/lets-go-object-oriented-programming-in-golang--cms-26540

### Polimorfismo

Polimorfismo é a capacidade de uma linguagem de tratar classes mais concretas de maneira mais abstrata. Go não possui herança em si, mas possui interfaces e é possível aplicar o conceito de polimorfismo quando uma estrutura implementa uma interface.

Ex.: Exemplo de polimorfismo
https://code.tutsplus.com/pt/tutorials/lets-go-object-oriented-programming-in-golang--cms-26540

## O conceito de Herança em Go 

A linguagem Go não tem herança, mas possui dois recursos capazes de oferecer a mesma economia de código, hierarquia e organização:Interfaces e Composições.

### Composição

É possível compor uma estrutura fazendo uso de outra previamente declarada, ou seja, os campos e métodos que o tipo “pai” possuir, passam a estar no tipo “filho”, enquanto que as propriedades do tipo “filho” permanecem exclusivas, sem passar a fazer parte do tipo “pai”.

Ex.: Exemplo de Composição
https://medium.com/@ViniciusPach_97728/go-composi%C3%A7%C3%A3o-vs-heran%C3%A7a-2e8b78928c26

O fato de uma composição existir não significa que o tipos “pai” e “filho” são do mesmo tipo. Para que isso ocorra, precisamos utilizar uma interface.

### Interface

Em Go, as Interfaces são a marca da orientação a objetos. Assim como em outras linguagens, as Interfaces não possuem implementação, sendo tipos que declaram um conjunto de métodos.

Para que um tipo assine uma interface,basta que o utilize todos os métodos disponibilizados por essa interface. Sendo assim, se quisermos que o tipo “pai” e “filho” sejam uma “família”, precisamos fazer com que os dois tipos implementem uma interface.Desse modo, além dos seus próprios tipos, “pai” e “filho” são também do tipo “família”.

Ex.: Exemplo de Interface
https://medium.com/@ViniciusPach_97728/go-composi%C3%A7%C3%A3o-vs-heran%C3%A7a-2e8b78928c26

### Generics

A linguagem go não possui Genéricos (salvo arrays, slices e maps, não é possível implementar seu próprio Genérico), pois os criadores se recusam a colocar algo que complique a linguagem e o compilador, sendo uma decisão criticada por muitos usuários.

Dentre os argumentos que condenam o criação de genéricos,temos os seguintes
* Genéricos introduzem mais complexidade na tipagem do sistema, o que implica em tornar o compilador mais lento
* Genéricos introduzem mais complexidade ao leitor do código pois se trata de outra abstração para entender.

Dentre os argumentos que defendem o uso e criação de genéricos temos o seguinte
* A ideia central de uma abstração é permitir que o usuário não se preocupe muito com o uso das mesmas, sendo os Genéricos uma forma de retirar a complexidade do código.

Todos os argumentos são válidos tendo como necessidade levar em conta o nível de conhecimento do usuário(programador) à respeito das abstrações da linguagem.

Exemplos dos genéricos de go:
* Array:

    var a [5]int

    var b [5][10]int

* Slices:

    var s []int

    var g []string{'g', 'o', 'l', 'a', 'n', 'g'}

* Maps:

    var m map[“chave”]int

## Classificação
* Imperativa:
O paradigma imperativo faz uso de enunciados e comandos que alteram o estado de um programa.A mudança de estado consiste na alteração do valor de um local de memória e destruição do anterior. Por meio da declaração de variáveis, é possível nomear um local da memória, atribuir um tipo ao valor armazenado e recuperar um valor de um determinado endereço de memória. Em Go é temos os seguintes exemplos:

```go
var a int
a = 10
a = 20
fmt.Println(a)
```

* Tipagem Estática:
A tipagem estática é a capacidade de uma linguagem auxiliar na segurança de tipos, onde a partir do momento em que a linguagem determina o tipo de uma variável, esse tipo não pode ser alterado durante a compilação. Embora seja de tipagem estática, existe um mecanismo Go que recorda um pouco as linguagens dinâmicas. Variáveis podem ser criadas sem se especificar um tipo caso seja atribuído um valor a mesma, porém, a partir dessa primeira atribuição, a variável assume o tipo do valor imputado até o fim da execução do programa. No exemplo abaixo é possível observar esse mecanismo.

```go
var b = 10
b = “String” //Resultaria em  um erro de compilação, pois após a primeira atribuição, o tipo da variável “b” foi setado para int pelo contexto
```

* Desempenho: 
Baseado em C,altamente otimizada
Originalmente concebida para ser uma linguagem de desenvolvimento de sistemas distribuídos, sistemas baseados em processadores multinúcleos e computação massiva, não sendo tão voltada para a criação de aplicativos, mas isso não ocorreu de fato, servindo em multipropósito, usada em muitas coisas para web, embora possa ser usada para qualquer coisa

* Linguagem de alto nível.
Compilado: Fornece desempenho que apenas código compilado é capaz de fornecer, por meio de dois compiladores gc e gccgo
Compilador resolver tudo rapidamente, sem contexto

* Simplista ao extrema: Como o foco é a velocidade, a simplicidade anda junto e foram removidos recursos de linguagens de alto nível, como classes, Heranças, Overloads  de métodos, Try/Catchs, Ternários e etc

* Modular, possui encapsulamento e polimorfismo
Não há mecanismos de herança
Evita recursos que a torne multiparadigma
Sintaxe sucinta
Sistema de análise de dependências

* Programação concorrente/paralela nativa
Multiplataforma
Atualmente possui versões para Windows, Linux, Mac OS, Free BSD e mobile
Open Source
Facilmente escalável


* GarbageCollector Nativo
Memory Safe: Go tem uma gestão própria de memória e threads transparente ao programador, fazendo a gestão de forma automática, evitando os problema de alocação e invasão de memória da linguagem C
    
## Go Vs C

### Funções
#### Em Go

```go
package main

import "fmt"

func add(x int, y int) int {
    return x + y
}

func main() {
    fmt.Println(add(42, 13))
}
```

#### Em C
```c
#include<stdio.h>

int add(int x,int y){
    return (x+y);
    
}

int main() {
   printf(" %d ",add(42,13));
}
```

### while
#### Em Go
```go
package main

import "fmt"

func main() {
    sum := 1
    for sum < 10 {
        sum += sum
    }
    fmt.Println(sum)
}
```

#### Em C
```c
#include<stdio.h>


int main() {
    int sum=1;
    while(sum<10){
        sum+=sum;
    }
    printf("%d \n",sum);
}
```

### Resultados Múltiplos
#### Em GO
```go
package main

import "fmt"

func swap(x, y int) (int, int) {
    return y, x
}

func main() {
    a, b := swap(2,8)
    fmt.Println(a, b)
}
```

#### Em C
```c
#include <stdio.h>

void swap(int *x, int *y){ 
   int temp;
   temp=*x;
   *x=*y;
   *y=temp;
}

int main(void) {
   int a=2, b=8 ;
   printf(" %d %d \n", a, b);
   swap(&a,&b);
   printf(" %d %d \n", a, b);
   return 0;
}
```

# Bibliografia

http://www.golangbr.org/doc/
http://goporexemplo.golangbr.org/
https://tableless.com.br/por-que-utilizar-gogolang-no-seu-backend/
https://pt.slideshare.net/natavenancio/linguagem-go-12238181
http://eltonminetto.net/post/2017-07-28-gerenciando-dependencias-golang/
https://github.com/golang/dep/issues/847
https://code.tutsplus.com/pt/tutorials/lets-go-object-oriented-programming-in-golang--cms-26540
