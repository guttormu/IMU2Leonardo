#include <errno.h>
#include <string.h>
#include <io.h>
#include <netdb.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <sys/uio.h>

const char* hostname = 0; /* wildcard */
const char* portname = "daytime";
struct addrinfo hints;
memset(&hints, 0, sizeof(hints));
hints.ai_family = AF_UNSPEC;
hints.ai_socktype = SOCK_DGRAM;
hints.ai_protocol = 0;
hints.ai_flags = AI_PASSIVE | AI_ADDRCONFIG;
struct addrinfo* res = 0;
int err = getaddrinfo(hostname, portname, &hints, &res);
if (err != 0) {
	die("failed to resolve local socket address (err=%d)", err);
}

int fd = socket(res->ai_family, res->ai_socktype, res->ai_protocol);
if (fd == -1) {
	die("%s", strerror(errno));
}

if (bind(fd, res->ai_addr, res->ai_addrlen) == -1) {
	die("%s", strerror(errno));
}

freeaddrinfo(res);

char buffer[548];
struct sockaddr_storage src_addr;

struct iovec iov[1];
iov[0].iov_base = buffer;
iov[0].iov_len = sizeof(buffer);

struct msghdr message;
message.msg_name = &src_addr;
message.msg_namelen = sizeof(src_addr);
message.msg_iov = iov;
message.msg_iovlen = 1;
message.msg_control = 0;
message.msg_controllen = 0;

ssize_t count = recvmsg(fd, &message, 0);
if (count == -1) {
	die("%s", strerror(errno));
}
else if (message.msg_flags&MSG_TRUNC) {
	warn("datagram too large for buffer: truncated");
}
else {
	handle_datagram(buffer, count);
}