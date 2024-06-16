import os
import firebase_admin
from firebase_admin import credentials
from firebase_admin import db
import urllib.parse
from datetime import datetime
import sys
print(sys.executable)

cred = credentials.Certificate("architecture-project-cc43f-firebase-adminsdk-ek5os-3b8c46693c.json")
firebase_admin.initialize_app(cred, {
    'databaseURL': 'https://architecture-project-cc43f-default-rtdb.firebaseio.com/'
})
ref = db.reference('/')
#funcion para leer txt
def read_text_file(file_path):
    try:
        with open(file_path, 'r') as file:
            contents = urllib.parse.quote(file.read())

            new_contents =""
            for i in contents:
                if i != "%":
                  new_contents = new_contents+i
                else:
                    break

            return new_contents
    except FileNotFoundError:
        print(f"Error: File '{file_path}' not found.")
        return None
    except Exception as e:
        print(f"Error: {e}")
        return None



def read_msg_file(file_path):
    try:
        with open(file_path, 'r') as file:
            contents = file.read()


            # Decode URL-encoded string
            decoded_contents = urllib.parse.unquote(contents)


            # Split the decoded contents at the first asterisk, take the first part
            before_asterisk = decoded_contents.split('*', 1)[0]


            # Split the part before the asterisk by line breaks and join with spaces
            parts = before_asterisk.split('\n')
            new_contents = ' '.join(part.strip() for part in parts if part.strip())


            return new_contents

    except FileNotFoundError:
        print(f"Error: File '{file_path}' not found.")
        return None
    except Exception as e:
        print(f"Error: {e}")
        return None


def file_was_updated(file_path, last_check_time_file):
    # Get the last modified time of the file
    file_mod_time = os.path.getmtime(file_path)
    try:
        # Try to read the last check time from the file
        with open(last_check_time_file, 'r') as f:
            last_check_time = float(f.read())
    except FileNotFoundError:
        # If the file does not exist, assume it's the first run and everything is new
        last_check_time = 0

    # Compare the last modified time with the last check time
    if file_mod_time > last_check_time:
        # If the file was modified since the last check, update the last check time
        with open(last_check_time_file, 'w') as f:
            f.write(str(file_mod_time))
        return True
    else:
        return False

def update_database(sender, receiver, message, password, message_file_path, last_check_time_file):
    if file_was_updated(message_file_path, last_check_time_file):
        try:
            # Check if the sender's name already exists as a parent node
            sender_ref = ref.child(sender)
            if not sender_ref.get():
                # If the sender does not exist, create the parent node along with child nodes
                sender_ref.set({
                    'information': {
                        'Nombre': sender,
                        'Contraseña': password
                    },
                    'messages': []
                })

            # Push the message to the "messages" child node
            sender_ref.child('messages').push({
                'Sender': sender,
                'Message': message,
                'Receiver': receiver
            })

            print("Data updated successfully.")
        except Exception as e:
            print(f"Error updating database: {e}")
    else:
        print("No new updates to process.")

def find_and_write_last_message(sender_name, receiver_name, output_file_path):
    messages_ref = ref.child(f'{sender_name}/messages')  # Assuming this is the correct path

    try:
        # Fetch messages for the sender
        messages = messages_ref.get()
        if messages:
            # Filter messages for the specified receiver
            filtered_messages = [msg for msg in messages.values() if msg.get('Receiver') == receiver_name]
            if filtered_messages:
                # Assuming the last message is what we're interested in
                last_message = filtered_messages[-1]['Message']
                # Write the last message to the specified file
                with open(output_file_path, 'w') as file:
                    file.write(last_message)
                print("Last message successfully written to file.")
            else:
                print(f"No messages for receiver: {receiver_name}")
        else:
            print(f"No messages found for sender: {sender_name}")
    except Exception as e:
        print(f"Error: {e}")

nombre_sender = read_text_file(r"C:\Users\sirok\Desktop\Arqui\Ejercicio3s\sender.txt")
nombre_receiver = read_text_file(r"C:\Users\sirok\Desktop\Arqui\Ejercicio3s\receiver.txt")
mensaje = read_msg_file(r"C:\Users\sirok\Desktop\Arqui\Ejercicio3s\respuesta.txt")
last_check_time_file = "respuesta.txt"
msg_path = r"C:\Users\sirok\Desktop\Arqui\Ejercicio3s\respuesta.txt"
contra = read_text_file(r"C:\Users\sirok\Desktop\Arqui\Proyecto_ensamblador\Contrasenas.txt")
# Ya sube todo a fire base, si esta el nodo padre con antelacion nada mas actualiza, si no pues crea todo.
# Update Firebase database

update_database(nombre_sender, nombre_receiver, mensaje, contra, msg_path, last_check_time_file)
ingreso = r"C:\Users\sirok\Desktop\Arqui\Ejercicio3s\ingreso.txt"

find_and_write_last_message(nombre_receiver,nombre_sender ,ingreso) # Esta tiene que ser la estructura de los argumentos dados








#funcion para pasar txt a json
#funcion para subir json a firebase segun nodo padre(destinatario)
#codigo para moverse en la base de datos para ver si un nodo existe, si no, se crea uno para almacenar los datos
#La plantilla de cada nodo seria, nodo padre, dentro va nodo informacion y nodo msg
#Dentro de nodo informacion va contraseña y nombre
#Dentro de msg van los nodos de los mensajes.





