# SE_lab_6

## Question #4:

### Identified Code Smells and Refactoring Suggestions

Below are the identified code smells in the clex.py file and the corresponding refactoring suggestions to address them. Each issue is explained with the reasons and appropriate solutions.

#### 1. Long Class (Large Class)

The Lexer class contains too many attributes, methods, and hard-coded token definitions, making it difficult to maintain and extend.

Solution:
We should extract the reserved words, token operators, and delimiters into separate modules or configuration files. For example:

```python
RESERVED_WORDS = (
    'AUTO', 'BREAK', 'CASE', 'CHAR', ...
)

TOKEN_OPERATORS = {
    'PLUS': r'\+',
    'MINUS': r'-',
    'TIMES': r'\*',
    ...
}
```

#### 2. Long Method (Long Method)

The **main** section combines file input/output, lexer handling, and directory creation into a single block, violating the single responsibility principle.

Solution:
We should split the **main** logic into smaller, more focused functions. For instance:

```python
def process_input_file(input_file):
    with open(input_file, "r") as file:
        return file.read()

def initialize_directories(output_dir):
    os.makedirs(output_dir, exist_ok=True)

def write_output_files(base_dir, output_file, token, index):
    with open(f"{base_dir}/{output_file}{index}.type", "w") as type_output:
        type_output.write(token.type)
    with open(f"{base_dir}/{output_file}{index}.value", "w") as value_output:
        value_output.write(token.value)

```

#### 3. Duplicated Code

File writing operations for typeOutput, valueOutput, and result are repeated in the loop, leading to redundancy.

Solution:
We should create a utility function for file writing:

```python
def write_to_file(filename, content):
    with open(filename, "w") as file:
        file.write(content)

```

Then replace the repetitive file handling with:

```python

write_to_file(f"result/{output_file}{counter}.type", tok.type)
write_to_file(f"result/{output_file}{counter}.value", tok.value)
```

#### 4. Comments Instead of Code (Comments)

The comments in the code (e.g., # ->, # ?) explain obvious parts and suggest unclear code.

Solution:
We should remove these unnecessary comments and replace unclear code with meaningful variable names. For example:

```python
TOKEN_PATTERNS = {
    'ARROW': r'->',
    'CONDOP': r'\?',
    ...
}
```

#### 5. Magic Strings (Magic Numbers and Strings)

Strings like "result/" and file suffixes (.type, .value) are hardcoded, making updates tedious.

Solution:
We should define constants for paths and suffixes:

```python
OUTPUT_DIR = "result"
TYPE_SUFFIX = ".type"
VALUE_SUFFIX = ".value"

```

#### 6. Poor Naming (Inconsistent Naming)

Variable names such as CFileName, outputFile, and tok are inconsistent and unclear.

Solution:
Rename variables for clarity and consistency:

CFileName → input_file
outputFile → output_file
tok → current_token
counter → token_index
Example:

```python
input_file = sys.argv[1]
output_file = sys.argv[2]
```

#### 7. Open-Closed Principle Violation

The hard-coded token definitions (t_PLUS, t_MINUS, etc.) make the lexer rigid and violate the Open-Closed Principle.

Solution:
We should load token definitions dynamically from an external configuration file (e.g., JSON or YAML):

```python
import json

def load_tokens_from_config(config_file):
    with open(config_file, "r") as file:
        return json.load(file)
```

TOKEN_CONFIG = load_tokens_from_config("tokens.json")

#### 8. Manual Resource Management (Resource Leak)

File objects are opened repeatedly without using with statements, which risks resource leaks.

Solution:
Use with statements to ensure files are closed properly:

```python
with open(f"result/{output_file}{counter}.type", "w") as type_output:
    type_output.write(tok.type)
```

#### 9. Hard-Coded Paths and Directory Creation (Shotgun Surgery)

Paths are built inline using string concatenation, making changes error-prone.

Solution:
Create a helper function to generate file paths:

```python
Copy code
def get_output_file_path(base_dir, file_name, suffix):
    return os.path.join(base_dir, f"{file_name}{suffix}")
```

Usage:

```python
path = get_output_file_path("result", output_file + str(counter), ".type")
```

#### 10. Insufficient Error Handling (Exception Handling Issues)

The code does not validate input arguments or handle missing files, leading to potential crashes.

Solution:
Add error handling for command-line arguments and file operations:

```python
if len(sys.argv) < 3:
    print("Usage: python clex.py <input_file> <output_file>")
    sys.exit(1)
```
