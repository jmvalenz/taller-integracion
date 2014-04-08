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

La configuración de la base de datos se encuentra en el archivo **config/database.yml** aunque recomiendo crear un archivo llamado **config/database.local.yml** para que puedan tener su propia configuración, sin publicar sus contraseñas al resto del grupo. Estos archivos están ignorados por git, así que no serán subidos cuando los creen. El formato es el mismo para ambos archivos (pueden copiar el original y modificar la información en su archivo local).
Recuerden que para que funcione la aplicación localmente, la base de datos debe existir, junto con el usuario señalado en el archivo de configuración. Además, recuerden que si hay **migraciones**, deben correrlas con el comando
    
    rake db:migrate 

Si tienen preguntas, **háganlas**.

Más avanzado
---------------

### Deploy

Para hacer deploy de la aplicación, siempre debe estar la última versión estable en el branch **master** en el repositorio de Github. Por lo que los pasos son (SIEMPRE QUE EL CÓDIGO SEA ESTABLE, y asumiendo que se encuentran en master)
    
    git status
    git add .
    git commit -m "algún comentario respecto al commit"
    git pull origin master
    git push origin master

    cap production deploy

El último comando va a correr todas las configuraciones necesarias en el servidor. Si no han creado llaves ssh, les va a pedir la contraseña del usuario passenger. Finalmente, si es necesario, corran las migraciones en el servidor con
    
    cap production deploy:migrate