```
ATENÇÃO: Esta documentação está deprecated, desde que adotamos SSL na entrega de vídeos. Estamos 
mantendo-a no ar somente por razões históricas. NÃO FUNCIONA. Está em nosso roadmap a criação
de um novo projeto focado em oferecer cache em provedores, stay tunned :-)
```

![Project logo](https://raw.githubusercontent.com/globocom/Globo-Live-Cache/master/logo.png)

#Introdução

A documentação a seguir descreve o que fazer para _cachear_ vídeos ao vivo da Globo.com.

__A entrega de vídeo ao vivo da Globo.com usa o protocolo HLS de acordo com a *RFC-2616* do HTTP 1.1:
 [seções 13](http://www.w3.org/Protocols/rfc2616/rfc2616-sec13.html) e
 [14](http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.9). Portanto, basta que seu servidor de proxy seja compatível com o padrão para que o _cache_ seja efetivo.__

_Cache_ é o mecanismo para armazenamento temporário de objetos, neste caso, pedaços de vídeos. Uma definição mais formal e completa sobre _web-caching_ pode ser encontrada na [wikipedia](http://pt.wikipedia.org/wiki/Web_cache).

__Web cache é um armazenamento temporário no disco rígido de páginas web, imagens e outros documentos utilizando técnicas de cache para reduzir o uso largura de banda disponível, aumentar a velocidade do acesso, entre outras vantagens.__

#Motivações para uso

A correta utilização de um _cache_ resulta em:

  - Economia de banda para ambos lados. <sup>[1]</sup>
  - Dimuição do atraso percebido. <sup>[1]</sup>
  - Melhoria da experiência do usuário, principalmente em momentos de pico.

#Funcionamento

Basicamente, quando um usuário atrás de um proxy configurado acessa um vídeo, ele realiza várias requisições _http_, possibilitando ao _proxy_ armazenar respostas para requisições idênticas, evitando o tráfego de saída para um arquivo anteriormente requisitado.

Um possível fluxo para exemplificar o funcionamento (USR1 e USR2 são dois usuários distintos na rede, PROXY um servidor proxy):
```
1. USR1 solicita vídeo 23.ts ao PROXY
2. PROXY ainda não tem cache para objeto 23.ts
3. PROXY solicita vídeo 23.ts a GLOBO.COM
4. PROXY armazena resposta da globo e atende USR1
5. USR2 solicita pedaço de vídeo 23.ts ao PROXY
6. PROXY responde diretamente ao USR2
```

#Implementação

Para implementar um _proxy_ você pode instalar o [Squid](http://www.squid-cache.org/). Instruções de instalação podem ser encontradas em seu [site oficial](http://wiki.squid-cache.org/SquidFaq/InstallingSquid).

Na instalação padrão, o Squid<sup>2</sup> já faz _caching_ baseado no cabeçalho das respostas, o que já atende aos vídeos ao vivo da Globo.com. Um exemplo de resposta pode ser visto abaixo:

```
< HTTP/1.0 200 OK
< Server: nginx
< Date: Fri, 15 Aug 2014 19:06:01 GMT
< Content-Type: video/mp2t
< Content-Length: 122200
< Expires: Fri, 15 Aug 2014 22:06:01 GMT
< Cache-Control: public, max-age=10800
< Via: 1.0 localhost (squid/3.1.19)
< Connection: keep-alive
```

Neste caso, o Squid vai seguir as regras do cabeçalho `Cache-Control:public, max-age=10800` que informa que este recurso pode ser _cacheado_ e por quanto tempo.

```
Uma observação importante é que nem todos os vídeos ao vivo da Globo.com são cacheáveis.
```

##Considerações

###O que deve ser _cacheado_?

As respostas do domínio `*.glbvid.com` e com extensão `ts`, mas **sempre respeitando os cabeçalhos**.

###O que não deve ser _cacheado_?

Os arquivos terminados com a extensão `m3u8` e `bin`. Fazer _caching_ desses arquivos pode degradar a experiência do usuário.

# Caso de Uso: Squid

## Requisitos
- [VirtualBox instalado](https://www.virtualbox.org/wiki/Downloads)
- [Vagrant instalado](http://www.vagrantup.com/downloads.html)
- [Git instalado](http://git-scm.com/downloads)

Execute os seguintes comandos:

```bash
$ git clone https://github.com/globocom/Globo-Live-Cache
$ cd Globo-Live-Cache
$ vagrant up
```

O comando `vagrant up` vai provisionar uma máquina virtual devidamente configurada com Squid3.

```
Nesta configuracão, todos os usuários tem acesso irrestrito.
```

Depois, configure seu _browser_ para apontar para o _proxy_ 192.168.33.10:3128. Caso queira verificar seu funcionamento:

```bash
$ vagrant ssh
vagrant@precise32: $ sudo tail -f /var/log/squid3/*log
```

Vale ressaltar que é possível exportar a máquina virtual do _Vagrant_ para provedores _cloud_, como por exemplo: [Amazon EC2](http://www.iheavy.com/2014/01/16/how-to-deploy-on-amazon-ec2-with-vagrant/) e [Digital Ocean.](https://www.digitalocean.com/community/tutorials/how-to-use-digitalocean-as-your-provider-in-vagrant-on-an-ubuntu-12-10-vps)

#Conclusão

Em testes realizados, percebemos que quando 10 usuários utilizam o _proxy_ para acessar vídeos ao vivo da Globo.com, o ganho é de aproximadamente 90% de banda sobre vídeos. Aumentando o número de usuários para 1000, o ganho chega a 99,9%. Assim, se considerarmos um arquivo de vídeo no _bitrate_ mais alto, o ganho pode ser em torno de 1Gb por pedaço de vídeo.

Os números acima são estimativas feitas a partir de testes com [ab](http://httpd.apache.org/docs/2.2/programs/ab.html) simulando usuários simultâneos com conexões para o maior bitrate.

Notas
=========
- [1]: [Wikipedia - Web cache](http://en.wikipedia.org/wiki/Web_cache)
- [2]: *Instalação padrão do squid3, considerando as devidas permissões
