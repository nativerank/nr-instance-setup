#!/usr/bin/env bash
FORMAT="--dev-slug=my-slug --site-url=www.domain.com"

if [[ -z "$1" ]] || [[ -z "$2" ]]; then
  printf -- "\033[31m ERROR: Invalid or no argument supplied \033[0m\n"
  printf -- "\033[32m CORRECT SYNTAX ---> ${FORMAT} \033[0m\n"
  exit 64
fi

for i in "$@"; do
  case $i in
  -d=* | --dev-slug=*)
    DEVSITE_SLUG="${i#*=}"
    ;;
  -s=* | --site-url=*)
    SITE_URL="${i#*=}"
    ;;
  --default)
    DEFAULT=YES
    ;;
  *)
    # unknown option
    ;;
  esac
done

#if [ -z "$DEFAULT" ]; then
#    echo "Error: Wrong Syntax";
#    echo ${FORMAT}
#    exit 1
# fi

if [[ $DEVSITE_SLUG == *.* ]]; then
  printf -- "\033[31m Devsite Slug con not contain a period (.) \033[0m\n"
  printf -- "\033[32m CORRECT SYNTAX ---> ${FORMAT} \033[0m\n"
  exit 64
fi

if [[ $DEVSITE_SLUG == */* ]]; then
  printf -- "\033[31m Devsite Slug con not contain a slash (/) \033[0m\n"
  printf -- "\033[32m CORRECT SYNTAX ---> ${FORMAT} \033[0m\n"
  exit 64
fi

if [[ $SITE_URL == *http* ]]; then
  printf -- "\033[31m ERROR: Site Url can not contain http \033[0m\n"
  printf -- "\033[32m CORRECT SYNTAX ---> ${FORMAT} \033[0m\n"
  exit 64
fi

if [[ $SITE_URL != www* ]]; then
  printf -- "\033[31m ERROR: Wrong Site URL format \033[0m\n"
  printf -- "\033[32m CORRECT SYNTAX ---> ${FORMAT} \033[0m\n"
  exit 64
fi

if [[ "${SITE_URL}" == */* ]]; then
  printf -- "\033[31m ERROR: Site Url can not contain a slash (/) \033[0m\n"
  printf -- "\033[32m CORRECT SYNTAX ---> ${FORMAT} \033[0m\n"
  exit 64
fi

if [[ "${SITE_URL}" == *. ]]; then
  printf -- "\033[31m ERROR: Site Url can not end with a period (.) \033[0m\n"
  printf -- "\033[32m CORRECT SYNTAX ---> ${FORMAT} \033[0m\n"
  exit 64
fi

if [[ "${SITE_URL}" == DOMAIN.com ]]; then
  printf -- "\033[31m ERROR: Be sure to replace DOMAIN.com with the domain for this account \033[0m\n"
  printf -- "\033[32m CORRECT SYNTAX ---> ${FORMAT} \033[0m\n"
  exit 64
fi

load_spinner() {
  sp='/-\|'
  printf ' '
  sleep 0.1
  COUNTER=1
  while [[ $COUNTER -lt 15 ]]; do
    printf '\b%.1s' "$sp"
    sp=${sp#?}${sp%???}
    sleep 0.1
    let COUNTER=COUNTER+1
  done
  printf -- "\n"
}

initiate_lighsailScript() {
  PUBLIC_IP="$(dig +short myip.opendns.com @resolver1.opendns.com)"
  printf -- "\033[33m Replace PUBLIC IP with production URL....... \033[0m"
  load_spinner
  sudo -u daemon wp search-replace "${PUBLIC_IP}" "${SITE_URL}" --skip-plugins=w3-total-cache
  sudo -u daemon wp search-replace "nrdevsites.com" "nativerank.dev" --skip-plugins=w3-total-cache
  sudo -u daemon wp search-replace "www.nativerank.dev" "nativerank.dev" --skip-plugins=w3-total-cache

  printf -- "\033[33m Replacing devsite slug (escaped) with production URL....... \033[0m"
  load_spinner
  sudo -u daemon wp search-replace "nativerank.dev\\/${DEVSITE_SLUG}" "${SITE_URL}" --skip-plugins=w3-total-cache

  printf -- "\033[33m Replacing devsite slug with production (unescaped) URL....... \033[0m"
  load_spinner
  sudo -u daemon wp search-replace "nativerank.dev/${DEVSITE_SLUG}" "${SITE_URL}" --skip-plugins=w3-total-cache

  printf -- "\033[33m Running the same replacements on Less and CSS\n"
  load_spinner

  sudo find /home/bitnami/apps/wordpress/htdocs/wp-content/themes/yootheme_child/less/src/ -name "*.less" -exec sed -i "s/nrdevsites.com/nativerank.dev/g" {} +
  sudo find /home/bitnami/apps/wordpress/htdocs/wp-content/themes/yootheme_child/less/src/ -name "*.less" -exec sed -i "s/www.nativerank.dev/nativerank.dev/g" {} +

  sudo find /home/bitnami/apps/wordpress/htdocs/wp-content/themes/yootheme_child/less/src/ -name "*.less" -exec sed -i "s/http:/https:/g" {} +
  sudo find /home/bitnami/apps/wordpress/htdocs/wp-content/themes/yootheme_child/less/src/ -name "*.less" -exec sed -i "s/https:\/\/nativerank.dev/nativerank.dev/g" {} +

  sudo find /home/bitnami/apps/wordpress/htdocs/wp-content/themes/yootheme_child/less/src/ -name "*.less" -exec sed -i "s/nativerank.dev\/${DEVSITE_SLUG}//g" {} +

  sudo find /home/bitnami/apps/wordpress/htdocs/wp-content/themes/yootheme_child/css/ -name "*.css" -exec sed -i "s/nrdevsites.com/nativerank.dev/g" {} +
  sudo find /home/bitnami/apps/wordpress/htdocs/wp-content/themes/yootheme_child/css/ -name "*.css" -exec sed -i "s/www.nativerank.dev/nativerank.dev/g" {} +

  sudo find /home/bitnami/apps/wordpress/htdocs/wp-content/themes/yootheme_child/css/ -name "*.css" -exec sed -i "s/http:/https:/g" {} +
  sudo find /home/bitnami/apps/wordpress/htdocs/wp-content/themes/yootheme_child/css/ -name "*.css" -exec sed -i "s/https:\/\/nativerank.dev/nativerank.dev/g" {} +

  sudo find /home/bitnami/apps/wordpress/htdocs/wp-content/themes/yootheme_child/css/ -name "*.css" -exec sed -i "s/nativerank.dev\/${DEVSITE_SLUG}//g" {} +

  printf -- "\033[33m Running the same replacements for Handlebars templates"
  load_spinner
  sudo find /home/bitnami/apps/wordpress/htdocs/wp-content/themes/yootheme_child/templates/ -name "*.hbs" -exec sed -i "s/nrdevsites.com/nativerank.dev/g" {} +
  sudo find /home/bitnami/apps/wordpress/htdocs/wp-content/themes/yootheme_child/templates/ -name "*.hbs" -exec sed -i "s/www.nativerank.dev/nativerank.dev/g" {} +
  sudo find /home/bitnami/apps/wordpress/htdocs/wp-content/themes/yootheme_child/templates/ -name "*.hbs" -exec sed -i "s/nativerank.dev\/${DEVSITE_SLUG}/${SITE_URL}/g" {} +
  sudo find /home/bitnami/apps/wordpress/htdocs/wp-content/themes/yootheme_child/templates/ -name "*.hbs" -exec sed -i "s/http:\/\/${SITE_URL}/https:\/\/${SITE_URL}/g" {} +

  printf -- "\033[33m Making it secure [http -> https]....... \033[0m"
  load_spinner
  sudo -u daemon wp search-replace "http://${SITE_URL}" "https://${SITE_URL}" --skip-plugins=w3-total-cache

  printf -- "\033[33m Setting site URL in WordPress....... \033[0m"
  load_spinner
  wp config set WP_SITEURL "https://${SITE_URL}"
  wp config set WP_HOME "https://${SITE_URL}"

  printf -- "\033[33m Adding default Pagespeed configuration....... \033[0m"
  load_spinner
  sudo sed -i "s/ModPagespeed on/ModPagespeed on\nModPagespeedRespectXForwardedProto on\nModPagespeedLoadFromFile \"https:\/\/${SITE_URL}\/\" \"\/opt\/bitnami\/apps\/wordpress\/htdocs\/\"\n/g" /opt/bitnami/apache2/conf/pagespeed.conf
  sudo sed -i "s/inline_css/inline_css,hint_preload_subresources/g" /opt/bitnami/apache2/conf/pagespeed.conf

  printf -- "\033[33m Removing Bitnami banner....... \033[0m"
  load_spinner
  sudo /opt/bitnami/apps/wordpress/bnconfig --disable_banner 1

  printf -- "\033[33m Setting up and activating Redis and W3 Total Cache....... \033[0m"
  load_spinner
  sudo apt-get install redis-server -y
  sudo -u daemon wp redis enable
  sudo -u daemon wp plugin activate w3-total-cache
  sudo wp config set WP_CACHE true --raw --type=constant --allow-root
  sudo -u daemon wp cache flush --skip-plugins=w3-total-cache
  printf -- "\033[33m Restarting apache....... \033[0m"
  load_spinner
  sudo /opt/bitnami/ctlscript.sh restart apache
}

printf -- "\033[32m  Initiating scripts... \033[0m\n"

initiate_lighsailScript
wait
printf -- "\033[32m Successfully migrated ${DEVSITE_SLUG} -> ${SITE_URL}. \033[0m\n"
exit 0
