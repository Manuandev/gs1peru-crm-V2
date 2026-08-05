# Certificados de confianza

Certificados intermedios que el servidor no envía en el handshake TLS — se cargan en
`SecurityContext.defaultContext` desde `main.dart` (ver `EnvConfig.certificadoConfianza`).

Colocar aquí (formato `.crt`, solo la parte pública — **nunca** un `.pfx`, ese tiene la llave
privada del servidor):

- `natcodee_intermedio.crt` — dev y qa (`natcodee.net`)
- `prod_intermedio.crt` — producción (`apicommerce.gs1pe.org.pe`)
