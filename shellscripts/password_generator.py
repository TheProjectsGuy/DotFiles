# Generate a random password (using only core python3 functionalities)
"""
    This program generates passwords for various use cases.
    
    The password length can be among the following:
    - "long" is more secure. Usually 32 bytes.
    - "medium" is workable in most cases. Usually 16 bytes.
    - "short" should be avoided in settings where security is crucial.
        Usually 8 bytes.
    
    The password can be of the following types:
    1. "urlsafe" password: URL-safe characters (base64). Works in most
        cases.
    2. "hyphen" separated: Separated by hyphens; groups of random 
        passwords and joined by hyphens (-). There is also a provision
        to include some extra (special) characters in the password.
    3. "random" password: Random characters selected from a set of
        'typeable' characters (letters, digits, special characters,
        punctuation, etc.). This suits most requirements for password
        strength.
    4. "number" password: Contains only digits (0-9).
    
    The program uses the following environment variables:
    - PWGEN_DEFAULT_TYPE: Default type of the password. Default is
        "urlsafe".
    - PWGEN_DEFAULT_LEN: Default length of the password. Default is
        "medium".
    - PWGEN_DEFAULT_EXTRA: Default extra characters to be included
        in the password.
    
    Tool uses only core python libraries (for portability)
    - secrets: https://docs.python.org/3/library/secrets.html
    - logging: https://docs.python.org/3/library/logging.html
    - argparse: https://docs.python.org/3/library/argparse.html
"""

# %%
import os
import sys
import string
import secrets
import logging
import argparse
logger = logging.getLogger(__name__)
sh = logging.StreamHandler()
sh.setLevel(logging.DEBUG)
sh.setFormatter(logging.Formatter(
        "[%(levelname)s]:[%(name)s]:[%(asctime)s]: %(message)s"))
logger.addHandler(sh)


# %%
class BetterFormatter(argparse.ArgumentDefaultsHelpFormatter,
        argparse.RawDescriptionHelpFormatter):
    pass

def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__, 
            formatter_class=BetterFormatter)
    parser.add_argument("-t", "--type", choices=["urlsafe", "hyphen",
            "random", "number"], help="Type of the password", 
            default=os.getenv("PWGEN_DEFAULT_TYPE", "urlsafe"))
    parser.add_argument("-l", "--len", choices=["short", "medium", 
            "long"], help="Length of the password", 
            default=os.getenv("PWGEN_DEFAULT_LEN", "medium"))
    parser.add_argument("-e", "--extra", help="Extra characters to "\
            "be included in the password (or segments). Only for "\
            "'hyphen' type.", 
            default=os.getenv("PWGEN_DEFAULT_EXTRA", None))
    args, unknown_args = parser.parse_known_args()
    if len(unknown_args) > 0:
        logger.warning(f"Unknown arguments: {unknown_args}")
    return args


# %%
# Return a random choice
def random_choice(alphabets, num_chars=1):
    """
        Return a random sampling of the characters in "alphabets"
        (choose "num_chars" times). Repetition is allowed.
    """
    return "".join(secrets.choice(alphabets) \
                    for _ in range(num_chars))


# %%
def get_urlsafe_passwd(length: str = "medium"):
    """
        Return a URL-safe password of "length" (should be in ["long",
        "medium", "short"]).
        
        Notes: https://docs.python.org/3/library/secrets.html#how-many-bytes-should-tokens-use
    """
    if length == "long":
        length = 32
    elif length == "medium":
        length = 16
    elif length == "short":
        length = 8
    else:
        raise ValueError(f"Unknown {length = }. Should be 'long', "\
                            "'medium', or 'short'")
    return secrets.token_urlsafe(length)


# %%
def get_hyphen_passwd(length: str = "medium", extra_chrs: str = ""):
    """
        Return a hyphen separated password of "length" (should be in
        ["long", "medium", "short"]).
    """
    if length == "long":
        bl, nb = 7, 4
    elif length == "medium":
        bl, nb = 5, 3
    elif length == "short":
        bl, nb = 4, 2
    else:
        raise ValueError(f"Unknown {length = }. Should be 'long', "\
                            "'medium', or 'short'")
    if extra_chrs is None:
        extra_chrs = ""
    chr_choices = string.ascii_letters + string.digits + extra_chrs
    return "-".join([random_choice(chr_choices, bl) \
                        for _ in range(nb)])


# %%
def get_random_passwd(length: str = "medium"):
    """
        Return a random password of "length" (should be in ["long",
        "medium", "short"]).
    """
    if length == "long":
        length = 42
    elif length == "medium":
        length = 21
    elif length == "short":
        length = 10
    else:
        raise ValueError(f"Unknown {length = }. Should be 'long', "\
                            "'medium', or 'short'")
    chr_choices = string.ascii_letters + string.digits \
                + string.punctuation
    return random_choice(chr_choices, length)


# %%
def get_number_passwd(length: str = "medium"):
    if length == "long":
        length = 22
    elif length == "medium":
        length = 10
    elif length == "short":
        length = 4
    else:
        raise ValueError(f"Unknown {length = }. Should be 'long', "\
                            "'medium', or 'short'")
    chr_choices = string.digits
    return random_choice(chr_choices, length)


# %%
if __name__ == "__main__":
    args = parse_args()
    if args.type == "urlsafe":
        passwd = get_urlsafe_passwd(args.len)
    elif args.type == "hyphen":
        passwd = get_hyphen_passwd(args.len, args.extra)
    elif args.type == "random":
        passwd = get_random_passwd(args.len)
    elif args.type == "number":
        passwd = get_number_passwd(args.len)
    else:
        raise ValueError(f"Unknown {args.type = }. Should be "\
                "'urlsafe', 'hyphen', or 'random'")
    print(passwd)

# %%
# Experimental section
