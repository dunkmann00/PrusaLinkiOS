//
//  PrintersCollectionViewController.swift
//  PrusaLink
//
//  Created by George Waters on 11/4/23.
//

import UIKit
import SwiftUI

class PrintersCollectionViewController<Content: View>: UICollectionViewController {
    
    let itemSpacing: CGFloat = 8
    let padding: CGFloat = 16
    let itemAspectRatio: CGFloat = 0.825
    let itemWidthRange: ClosedRange<CGFloat> = 160.0...200.0
    
    var printerBoxes: [PrinterBox<Content>] = []
    
    var printers: [Printer] {
        printerBoxes.map { $0.printer }
    }
    
    var content: (Binding<Printer>) -> Content
        
    var dataSource: UICollectionViewDiffableDataSource<Int, PrinterBox<Content>>?
    
    let coordinator: _PrintersCollectionView<Content>.Coordinator
    
    var isViewUpdate = false
    
    var collectionViewAdjustedContentInsetSize = CGSize.zero
    var rotationAnimator = UIViewPropertyAnimator(duration: 0.1, curve: .linear)
    
    init(_ printers: [Printer], coordinator: _PrintersCollectionView<Content>.Coordinator, @ViewBuilder content: @escaping (Binding<Printer>) -> Content) {
        self.coordinator = coordinator
        self.content = content
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
        self.printerBoxes = printers.map {printer in
            let printerBox = PrinterBox(printer, content: content)
            printerBox.delegate = self
            return printerBox
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.collectionViewLayout = createLayoutForSize(collectionViewAdjustedContentInsetSize)
        setupDataSource()
        
        collectionView.alwaysBounceVertical = true
        collectionView.contentInset = .init(top: padding, left: padding, bottom: padding, right: padding)
        collectionView.contentInsetAdjustmentBehavior = .always
        
        installsStandardGestureForInteractiveMovement = true
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        // Needed for rotations, the correct size info is not in viewWillTransition
        updateCollectionViewItemSize()
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        // Needed for rotations, the correct size info is not in viewWillTransition
        updateCollectionViewItemSize()
    }
    
    func updateCollectionViewItemSize() {
        let totalInsets = collectionView.contentInset + view.safeAreaInsets
        let collectionViewAdjustedContentInsetSize = view.frame.inset(by: totalInsets).size
        if collectionViewAdjustedContentInsetSize.width != self.collectionViewAdjustedContentInsetSize.width {
            self.collectionViewAdjustedContentInsetSize = collectionViewAdjustedContentInsetSize
            guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
                return
            }
            let itemSize = getItemSizeForSize(collectionViewAdjustedContentInsetSize)
            flowLayout.itemSize = itemSize
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate { [self] context in
            // On the iPad the rotation animation looks great, but on iPhone, -_- , not so much.
            // I tested this with iOS 16, so I'm curious if this will be fixed in the newer OS.
            // But for now, we just hide the rotation animation on the iPhone.
            if UIDevice.current.userInterfaceIdiom == .phone {
                collectionView.alpha = 0
            }
        } completion: { context in
            if UIDevice.current.userInterfaceIdiom == .phone {
                self.rotationAnimator.addAnimations {
                    self.collectionView.alpha = 1
                }
                self.rotationAnimator.startAnimation()
            }
        }
    }
    
    func createLayoutForSize(_ contentSize: CGSize) -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = getItemSizeForSize(contentSize)
        layout.minimumInteritemSpacing = itemSpacing
        layout.minimumLineSpacing = itemSpacing
        return layout
    }
    
    func getItemSizeForSize(_ contentSize: CGSize) -> CGSize {
        var columns = 2
        var itemWidth: CGFloat = .greatestFiniteMagnitude
        while itemWidth > itemWidthRange.upperBound {
            let totalItemHSpace = contentSize.width - (itemSpacing * CGFloat(columns - 1))
            itemWidth = totalItemHSpace / CGFloat(columns)
            columns += 1
        }
                
        itemWidth = max(itemWidth, itemWidthRange.lowerBound)
        
        let itemSize = CGSize(width: itemWidth, height: itemWidth / itemAspectRatio)
        return itemSize
    }
    
    func setupDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, PrinterBox<Content>> { cell, indexPath, printerBox in
            cell.contentConfiguration = UIHostingConfiguration {
                PrintersCollectionViewCell(printerBox: printerBox)
            }
            .margins(.all, 0)
        }
        
        let dataSource = UICollectionViewDiffableDataSource<Int, PrinterBox>(collectionView: collectionView) { collectionView, indexPath, printerBox in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: printerBox)
        }
        
        dataSource.reorderingHandlers.canReorderItem = { _ in return true }
        
        dataSource.reorderingHandlers.didReorder = { [weak self] transaction in
            guard let self = self else { return }
            
            self.printerBoxes = transaction.finalSnapshot.itemIdentifiers
            coordinator.parent.printers = self.printers
        }
        
        dataSource.apply(getSnapshot(printerBoxes), animatingDifferences: true)
        
        self.dataSource = dataSource
    }
    
    func getSnapshot(_ newPrinterBoxes: [PrinterBox<Content>]) -> NSDiffableDataSourceSnapshot<Int, PrinterBox<Content>> {
        var snapshot = NSDiffableDataSourceSnapshot<Int, PrinterBox<Content>>()
        snapshot.appendSections([0])
        snapshot.appendItems(newPrinterBoxes)
        return snapshot
    }
    
    func updatePrinterBoxesWithPrinters(_ printers: [Printer]) {
        guard printers != self.printers else {
            return
        }
        isViewUpdate = true
        
        let printerBoxes = printers.map { printer in
            guard let printerBox = self.printerBoxes.first(where: { $0.printer.id == printer.id }) else {
                let newPrinterBox = PrinterBox(printer, content: content)
                newPrinterBox.delegate = self
                return newPrinterBox
            }

            if printerBox.printer != printer {
                printerBox.printer = printer
            }
            return printerBox
        }
        
        self.printerBoxes = printerBoxes
        dataSource?.apply(getSnapshot(printerBoxes), animatingDifferences: true)
        isViewUpdate = false
    }
    
    func updatePrinterBoxesWithContent(@ViewBuilder _ content: @escaping (Binding<Printer>) -> Content) {
        isViewUpdate = true
        
        printerBoxes.forEach { $0.content = content }
        
        self.content = content
        
        isViewUpdate = false
    }
    
    func scrollToPrinter(_ printer: Printer) -> Bool {
        guard let printerBox = printerBoxes.first(where: { $0.printer.id == printer.id }),
              let indexPath = dataSource?.indexPath(for: printerBox) else {
            return false
        }
        collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
        return true
    }
}

extension PrintersCollectionViewController: PrinterBoxDelegate {
    func printerDidChangeInBox<Content: View>(_ printerBox: PrinterBox<Content>) {
        if !isViewUpdate {
            coordinator.parent.printers = printers
        }
    }
}

struct PrintersCollectionViewCell<Content: View>: View {
    @ObservedObject var printerBox: PrinterBox<Content>
    
    var body: some View {
        printerBox.content($printerBox.printer)
    }
}
