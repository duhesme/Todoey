import UIKit
import RealmSwift
import ChameleonFramework

class CategoryTableViewController: SwipeTableViewController {

    let realm = try! Realm()
    
    var categories: Results<Category>?
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        
        loadCategories()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        guard let navBar = navigationController?.navigationBar else {
            fatalError("Navigation bar does not exist.")
        }
        
        guard let colour = UIColor(hexString: "1D9BF6") else {
            fatalError("Cannot instantiate navigation bar color.")
        }
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(colour, returnFlat: true)]
        
        if #available(iOS 15, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = colour
            appearance.largeTitleTextAttributes = titleTextAttributes
            appearance.titleTextAttributes = titleTextAttributes
            navBar.standardAppearance = appearance;
            navBar.scrollEdgeAppearance = navBar.standardAppearance
        } else {
            navBar.backgroundColor = colour
            navBar.barTintColor = colour
            navBar.tintColor = ContrastColorOf(colour, returnFlat: true)
            navBar.largeTitleTextAttributes = titleTextAttributes
            navBar.titleTextAttributes = titleTextAttributes
        }
        
        searchBar.barTintColor = colour
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new Todoey category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add category", style: .default) { [weak self] action in
            guard let text = textField.text else {
                return
            }
            
            if !text.isEmpty {
                let newCategory = Category()
                newCategory.name = text
                newCategory.colour = UIColor.randomFlat().hexValue()
                self?.save(category: newCategory)
            }
        }
        alert.addAction(action)
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create new category"
            textField = alertTextField
        }
        
        present(alert, animated: true)
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        cell.textLabel?.text = categories?[indexPath.row].name ?? "No categories added yet."
        
        guard let categoryColour = UIColor(hexString: categories?[indexPath.row].colour ?? "1D9BF6") else {
            fatalError()
        }
        
        cell.backgroundColor = categoryColour
        cell.textLabel?.textColor = ContrastColorOf(categoryColour, returnFlat: true)
        
        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }
    
    // MARK: - Table view data manipulation

    func save(category: Category) {
        do {
            try realm.write({
                realm.add(category)
            })
        } catch {
            print("Error saving category: \(error)")
        }
        
        tableView.reloadData()
    }
    
    func loadCategories() {
        categories = realm.objects(Category.self)
        
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        super.updateModel(at: indexPath)
        
        if let category = categories?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(category)
                }
            } catch {
                print("Error deleting category: \(error)")
            }
        }
    }
    
}

extension CategoryTableViewController: UISearchBarDelegate {
    
}

