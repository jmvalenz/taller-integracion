Taller de Integración
===========

Para comenzar
---------------

### Instalar Ruby y Rails

**Para los que tengan Mac o Ubuntu:**

    \curl -sSL https://get.rvm.io | bash -s stable --rails

**Para los que tengan Windows (instalen Ubuntu) revisen [http://rubyinstaller.org/downloads](este link)**

### Instalar Postgres

Para este proyecto usaremos como motor de base de datos **Postgres**.

En Mac se puede descargar con [http://brew.sh/](Homebrew), [http://www.macports.org/](MacPorts) o desde [http://www.postgresql.org.es/descargas](su página web). Recomiendo la primera opción. En ese caso, deben tener instalado Homebrew, y correr la siguiente línea en la consola:

    brew install postgresql

En Windows supongo que se puede descargar desde la [http://www.postgresql.org.es/descargas](página web).

La configuración de la base de datos se encuentra en el archivo **config/database.yml** aunque recomiendo crear un archivo llamado **config/database.local.yml** para que puedan tener su propia configuración, sin publicar sus contraseñas al resto del grupo. Estos archivos están ignorados por git, así que no serán subidos cuando los creen. El formato es el mismo para ambos archivos (pueden copiar el original y modificar la información en su archivo local).

Si tienen preguntas, **háganlas**.