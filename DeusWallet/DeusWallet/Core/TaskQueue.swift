import Foundation

class TaskQueue<Element> {
    private var elements = [Element]()
    private let queue = DispatchQueue(label: "deus.TaskQueue")

    var isEmpty: Bool {
        return queue.sync { elements.isEmpty }
    }

    var front: Element? {
        return queue.sync { elements.first }
    }

    func enqueue(_ element: Element) {
        queue.async {
            self.elements.append(element)
        }
    }

    @discardableResult
    func dequeue() -> Element? {
        return queue.sync {
            if elements.isEmpty {
                return nil
            } else {
                return elements.removeFirst()
            }
        }
    }
}
