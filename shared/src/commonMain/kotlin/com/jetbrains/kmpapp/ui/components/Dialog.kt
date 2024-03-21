package com.jetbrains.kmpapp.ui.components

interface Dialog {
    fun render()
    fun createButton(text: String): Button
}