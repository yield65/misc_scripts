# Sender Policy Framework

### Descripción

El registro o registros SPF permiten lo siguiente:
* Disminuir la cantidad de SPAM que es enviado a nombre de nuestra empresa utilizando nuestro dominio tratando de engañar a nuestros clientes o contactos.
* Elevar el nivel de efectividad de nuestros filtros de correo al configurar reglas que eliminen o pongan en cuarentena los correos que recibimos que fallen en validar su registro SPF
* Disminuir la probabilidad de que nuestro dominio sea publicado en listas negras de SPAM

### Implementación
Agregar el registro SPF que autorice los servidores SMTP de la compañía en los DNS del dominio, autoritativos y esclavos.

**Ejemplo registro SPF**
```
"v=spf1 ip4:192.168.2.25 include:_spf.corporativo.com ~all"
```
**Header SPF válido**
```
Received-SPF: pass (destinatario.com: domain of contacto@corporativo.com designates 192.168.2.25 as permitted sender) client-ip=192.168.1.38;
```
**Header SPF inválido**
```
Received-SPF: softfail (destinatario.com: domain of transitioning contacto@corporativo.com does not designate 117.247.211.154 as permitted sender) client-ip=117.247.211.154;
```
**Política**
* Crear un filtro que sólo permita en Inbox el string que concuerde con un SPF válido

# DomainKeys Identified Mail

### Descripción
DKIM permite crear un sistema de confianza en la comunicación B2B y B2C ya que permite una validación por firma digital a nivel DNS de nuestros correos.
DKIM realiza dos funciones, firma de los correos enviados y verificación de firma en los correos entrantes.
DKIM se debe implementar después de SPF.
Es importante implementar correctamente DKIM ya que este este sistema permite el acceso al siguiente método de confianza en correo electrónico y permite el intercambio seguro de correo entre empresas ó dominios que ya tienen DKIM implementado.
Si las políticas de correo o los filtros de correo permiten holgura en el campo SPF, la validación por DKIM es absoluta y si la firma digital no coincide en el encabezado del mensaje, entonces es totalmente seguro que el mensaje es SPAM.

**Header con DKIM válido**
```
DKIM-Signature: v=1; a=rsa-sha256; d=example.net; s=brisbane;
     c=relaxed/simple; q=dns/txt; l=1234; t=1117574938; x=1118006938;
     h=from:to:subject:date:keywords:keywords;
     bh=MTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTI=;
     b=dzdVyOfAKCdLXdJOc9G2q8LoXSlEniSbav+yuU4zGeeruD00lszZ
              VoG4ZHRNiYzR
```
```
Authentication-Results: mail.dominio.com;
       dkim=pass header.i=@corporativo.com;
       spf=pass (corporativo.com: domain of contacto@corporativo.com designates 192.168.2.25 as permitted sender) smtp.mailfrom=contacto@corporativo.com
```
Aquí se puede ver que se validaron dos campos, SPF primero (el más básico) y DKIM después, con una firma RSA-SHA256 la cual es única por servidor de correo y dominio.

**Política**
* Crear filtros que separen los correos con registro SPF y/o DKIM para darles prioridad
* Crear un filtro que separe los correos con SPF asignándoles menor prioridad
* Crear un filtro que almacene los correos con registros SPF neutros separados de los demás
* Crear un filtro que califique como SPAM todos los correos que han fallado textualmente la validación SPF y/o DKIM 

# Domain-based Message Authentication, Reporting and Conformance (DMARC)

### Descripción
DMARC se asegura de que el correo electrónico recibido por el servidor de correo cumpla los estándares SPF y DKIM bloqueando todo intento de falsificación, phishing y spoofing de mensajes.
Para que un mensaje sea calificado por DMARC como válido, se deben cumplir todas las condiciones de verificación con SPF y DKIM sin margen de error.
De no hacerlo, DMARC permite informar a los remitentes del por qué su correo fué rechazado.
DMARC permite establecer estas políticas a nivel DNS en los servidores de la empresa.
Si se tiene un canal de confianza con otras empresas, se pueden comenzar a establecer políticas DMARC que invariablemente y sin error ignorarán los correos fraudulentos.
***Header con DMARC válido***
```
Authentication-Results: mx.google.com;
       dkim=pass header.i=@2hmexico.com.mx;
       spf=pass (google.com: domain of jaimev@2hmexico.com.mx designates 2607:f8b0:400e:c00::22a as permitted sender) smtp.mailfrom=jaimev@2hmexico.com.mx;
       dmarc=pass (p=NONE dis=NONE) header.from=2hmexico.com.mx
```
***Header con DMARC inválido***
```
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning yield@2hmexico.com.mx does not designate 117.247.211.154 as permitted sender) smtp.mailfrom=yield@2hmexico.com.mx;
       dmarc=fail (p=NONE dis=NONE) header.from=2hmexico.com.mx
```
**Política**

Existen tres tipos de manejo de mensajes **inválidos** con DMARC

    1. None
    2. Reject
    3. Quarantine

Se recomienda comenzar en "none" e ir elevando poco a poco el nivel de cumplimiento poco a poco.
