//
//  ViewController.swift
//  WebServices
//
//  Created by Juan Bonforti on 30/05/2020.
//  Copyright © 2020 Juan Bonforti. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var textField: UITextField!
    
    var palabra:String? // Opcional, puede ser blanco/nil
    
    // URL Wikipedia para Request: https://es.wikipedia.org/w/api.php?action=query&prop=extracts&format=json&exintro=&titles=sega
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func searchResult(_ sender: Any) {
        // Asigno en una variable, el valor del textField
        palabra = textField.text!
                
        // Defino URL a utilizar
        // Manejo de los espacios en una URL del lado de la UI. palabra?.replacingOccurrences(of: " ", with: "%20");
        let urlToSearch = "https://es.wikipedia.org/w/api.php?action=query&prop=extracts&format=json&exintro=&titles=\(palabra!.replacingOccurrences(of: " ", with: "%20"))"
                        
        // Creo el objeto URL para ser llamado
        let objUrl = URL(string: urlToSearch)!; // devuelve un optional, por lo que debo destaparlo al utilizarlo con !
        
        // hHcemos el request
        let task = URLSession.shared.dataTask(with: objUrl) { (data, response, error) in
            if error != nil {
                // Hubo error, por lo tanto imprimo
                print(error!)
            }else{
                
                // Para el manejo de errores, en la respuesta a un request, hacemos un DO Try Catch
                do {
                    // Utilizamos la clase JSONSerialization, para la manipulacion de la respuesta JSON
                    // le pasamos la data! como parametro al with
                    // indicamos en options JSONSerialization.ReadingOptions.mutableContainers para decir q al objeto le podremos hacer cambios.
                    // as AnyObject es por que no tenemos una clase definida para el modelo de datos, por lo que aceptamos cualquiera. Luego lo cambiamos por String:Any
                    let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String:Any]
                    //print(json);
                    let jsonToShow = self.renderHTML(json: json);
                    
                    print(jsonToShow);
                                        
                    // Coloco el HTML devuelto, en el WebView
                    DispatchQueue.main.sync(execute: {
                        self.webView.loadHTMLString(jsonToShow, baseURL: nil)
                    })
                } catch {
                    print("error en el catch, no es un JSON valido")
                }
            }
            
        }
        task.resume()
        print(palabra!);
    }
    
    
    func renderHTML(json:[String:Any]) -> String {
        let jsonQuery = json["query"] as! [String:Any]
        //print(jsonQuery);
        
        let jsonPages = jsonQuery["pages"] as! [String:Any]
        //print(jsonPages)
        
        let pagesId = jsonPages.keys; // Obtengo todas las keys del JSON si tuviese donde estoy parado. Puedo recorrerlas con for
        let jsonId = jsonPages[pagesId.first!] as! [String:Any]
        //print(jsonId)
        
        let jsonExtract = jsonId["extract"] as! String
        //print(jsonExtract)
        
        // [String:Any] en las respuestas a los jSON corresponde a que la clave:valor, el valor puede ser de cualquier tipo pero la clave es String siempre por ser JSON.
        
        guard !jsonExtract.isEmpty else { DispatchQueue.main.sync(execute: {
            // Create and configure the alert controller.
            let alert = UIAlertController(title: "Error",
                  message: "La palabra buscada, no retorna resultados...",
                  preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The \"OK\" alert occured.")
            }))
            self.present(alert, animated: true, completion: nil)
        }); return "" }
                
        return jsonExtract;
        
    }


}

