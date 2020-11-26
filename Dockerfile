ARG BUILD_NO
FROM centos
MAINTAINER nikhil pandit
RUN yum install -y httpd
RUN echo "<!DOCTYPE html>" > /var/www/html/index.html
RUN echo "<html>" >> /var/www/html/index.html
RUN echo "<body>" >> /var/www/html/index.html
RUN echo '<h1 style="color:blue;text-align:center;font-size:80px;">NIKHIL PANDIT</h1>' >> /var/www/html/index.html
RUN echo '<p style="color:red;text-align:center;font-size:40px;">DEVOPS ENG.</p>' >> /var/www/html/index.html
RUN echo '<p style="color:green;text-align:center;font-size:30px;">DATE: <MY-DATE>.</p>' >> /var/www/html/index.html
RUN echo '<p style="color:red;text-align:center;font-size:40px;">BUILD NO : ${BUILD_NO} </p>' >> /var/www/html/index.html
RUN echo "</body>" >> /var/www/html/index.html
RUN echo "</html>" >> /var/www/html/index.html

RUN sed -i "s~<MY-DATE>~$(date '+%d-%b-%Y-%H-%M-%S')~g" /var/www/html/index.html
RUN sed -i "s~<HOSTNAME>~$(hostname)~g" /var/www/html/index.html
EXPOSE 80

CMD ["httpd", "-D", "FOREGROUND"]
