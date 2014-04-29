Taller de Integración
===========

Para comenzar
---------------

### Instalar Ruby y Rails

**Para los que tengan Mac o Ubuntu:**

    \curl -sSL https://get.rvm.io | bash -s stable --rails

**Para los que tengan Windows (instalen Ubuntu) revisen [este link](http://rubyinstaller.org/downloads)**

### Instalar Postgres

Para este proyecto usaremos como motor de base de datos **Postgres**.

En Mac se puede descargar con [Homebrew](http://brew.sh/), [MacPorts](http://www.macports.org/) o desde [su página web](http://www.postgresql.org.es/descargas). Recomiendo la primera opción. En ese caso, deben tener instalado Homebrew, y correr la siguiente línea en la consola:

    brew install postgresql

En Windows supongo que se puede descargar desde la [página web](http://www.postgresql.org.es/descargas).

Para configurar la base de datos en la aplicación, deben crear este archivo: **config/settings/development.local.yml**. La información que deben incluir en él pueden sacarla del archivo **config/settings/production.yml** que tiene la configuración de la base de datos de producción (la que está en el servidor).
Recuerden que para que funcione la aplicación localmente, la base de datos debe existir, junto con el usuario señalado en el archivo de configuración. Con el siguiente comando se pueden crear las base de datos:

    rake db:create

Además, recuerden que si hay **migraciones**, deben correrlas con el comando
    
    rake db:migrate 

Si tienen preguntas, **háganlas**.

Más avanzado
---------------

### Deploy

Para hacer deploy de la aplicación, siempre debe estar la última versión estable en el branch **master** en el repositorio de Github. Por lo que los pasos son (SIEMPRE QUE EL CÓDIGO SEA ESTABLE, y asumiendo que se encuentran en master)
    
    git status
    git add -p
    git commit -m "algún comentario respecto al commit"
    git pull origin master
    git push origin master

    cap production deploy

El comando git add -p les permite seleccionar qué desean incluir en el próximo commit.
El último comando va a correr todas las configuraciones necesarias en el servidor. Si no han creado llaves ssh, les va a pedir la contraseña del usuario passenger. Finalmente, si es necesario, corran las migraciones en el servidor con
    
    cap production deploy:migrate

Manejo de configuraciones
---------------

### Rails Config

Hay una gema llamada rails_config que permite tener la información de la aplicación en un solo archivo, y separarlo para producción y desarrollo.
Toda la información local (base de datos de su computador, llaves de apis o cualquier cosa que debiera ser diferente al servidor de producción) debe estar guardada en el archivo **config/settings/development.local.yml**. Así, además de no publicar sus contraseñas al resto del grupo, podemos tener todo más organizado.

Desarrollo
---------------

### Convenciones

Para tener todo bien organizado y no tener conflictos posibles, propongo las siguientes convenciones (los que ya empezaron a hacer cosas pueden adaptarlas a esto o dejarlo así como está, pero bien comentado).

*   Nombres de variables: una_variable = "contenido"
*   Nombres de modelos en inglés
*   Normalizar la base de datos (para aprovechar funcionalidades de Rails)
*   Si es necesario comentar mucho el código, escribir el código de nuevo de manera más simple