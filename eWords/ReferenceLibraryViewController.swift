import UIKit

class ReferenceLibraryViewController: UIReferenceLibraryViewController {
    var delegate: WordsViewControllerDelegate?
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        delegate?.presentAlert()
    }
}
